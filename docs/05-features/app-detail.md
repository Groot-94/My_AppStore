# 피처 · AppDetail (앱 상세)

## 개요
여러 피처(Search/Today/Apps/Games/Arcade/SeeAll)에서 공통 진입하는 앱 상세 화면. `appID`만 받아 Lookup으로 상세를 채운다.

## 진입
- 입력: `appID: Int`.
- `AppDetailInterface.AppDetailBuilder.build(appID:)`로 생성. 다른 피처는 이 계약만 주입받아 push.
- 구현체 `DefaultAppDetailBuilder`는 App(Composition Root)이 생성해 각 피처에 주입.

## UI 스케치

```
┌─────────────────────────────┐
│ ◀ 검색                       │ ← 진입 피처의 back
│                             │
│ ┌────┐  앱이름               │ ← 헤더
│ │ 📱 │  개발사               │
│ └────┘  [받기]          (⋯) │
│                             │
│ ★4.1     │  4+  │ #1 소셜 │▶ │ ← 메타 스트립(가로 스크롤)
│ 2.3만 개  │ 연령 │  차트     │
│ ─────────────────────────── │
│ ┌──────┐ ┌──────┐ ┌──────┐  │ ← 스크린샷 페이저
│ │      │ │      │ │      │▶ │   (ScreenshotPager)
│ │      │ │      │ │      │  │
│ └──────┘ └──────┘ └──────┘  │
│ ─────────────────────────── │
│ 설명 텍스트 3~4줄까지만…      │
│                      더 보기 │
│ ─────────────────────────── │
│ 새로운 기능                  │
│ 버전 5.2.1 · 3일 전          │
│ 릴리스 노트…                 │
│ ─────────────────────────── │
│ 정보                         │
│  크기            215.4MB    │
│  카테고리         소셜        │
│  호환성          iOS 15.0+  │
│  언어            한국어 외 3  │
│  연령 등급        4+         │
│         (세로 스크롤)         │
└─────────────────────────────┘
```

헤더/받기 버튼/스크린샷 페이저/평점 = DesignSystem 공통 컴포넌트(목록 셀과 스타일 일관).

## UI 흐름 (버튼 → 동작 → 상태/화면 변화)

```
 어느 피처든 항목 탭 → build(appID:) 로 생성·push
   ▼
 loading (스켈레톤)
   │  LoadAppDetailUseCase → AppDetailRepository
   │   ├─ Persistence.Cache 조회 ─ hit ─▶ 즉시 loaded (API 호출 생략)
   │   └─ miss ─▶ ITunesClient.lookup(id) ─▶ 캐시 저장
   ├─ 결과 1건 ─▶ loaded(AppDetail) — 전체 섹션 렌더
   └─ 결과 0건(삭제/미출시) ─▶ failed("앱을 찾을 수 없음")
        └─ [다시 시도] ─▶ loading 재진입 (0건이면 재시도 무의미 → 버튼 대신 안내만)

 loaded 에서
   ├─ [받기 버튼 탭]        ─▶ 버튼 UI 변화만(다운로드/결제 없음)
   ├─ [(⋯) 메뉴 탭]         ─▶ 동작 없음(UI만)
   ├─ [메타 스트립 스와이프]  ─▶ 가로 스크롤(상태 변화 없음)
   ├─ [스크린샷 스와이프]    ─▶ 페이지 전환(상태 변화 없음)
   ├─ [더 보기 탭]          ─▶ 설명 전체 펼침(레이아웃만 변경, 상태 동일)
   └─ [◀ back]             ─▶ 진입 피처로 pop
```

## 상태 (ViewModel)
```swift
@Observable @MainActor
final class AppDetailViewModel {
    enum State { case loading, loaded(AppDetail), failed(String) }
    private(set) var state: State
    let appID: Int
    func load() async
}
```

## Domain / Data (피처 소유)
- **엔티티**: `AppDetail` — 풀 스펙: `{ id, name, sellerName, genre, iconURL, screenshotURLs, description, releaseNotes, version, updatedAt, rating, ratingCount, priceText, contentRating, fileSizeBytes, minimumOSVersion, languages }`.
- **UseCase**: `LoadAppDetailUseCase` — `func execute(appID: Int) async throws -> AppDetail`.
- **Repository**: `AppDetailRepository` → `DefaultAppDetailRepository` — `Persistence.Cache` 우선, miss 시 `ITunesClient.lookup` → DTO → `AppDetail` 매핑 → 캐시 저장.

## 엣지 케이스
- Lookup 결과 0건(삭제/미출시 앱): "앱을 찾을 수 없음".
- 스크린샷 없음: 페이저 섹션 숨김.
- 설명 매우 김: 초기 3~4줄 + "더 보기".
- releaseNotes 없음: "새로운 기능" 섹션 숨김.

## 공통화 메모
- 헤더/받기 버튼/스크린샷 페이저/평점 뷰는 **DesignSystem**에 두어 목록 셀과 스타일 일관성 유지.
- DesignSystem 컴포넌트는 `AppDetail` 엔티티를 모른다 — ViewModel이 구성 모델로 변환해 전달.
