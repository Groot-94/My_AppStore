# 피처 · Apps (앱)

## 개요
앱 중심의 둘러보기 탭. 추천 캐러셀 + 인기 차트 + 카테고리. App Store의 "앱" 탭.

## UI 스케치

```
┌─────────────────────────────┐
│ 앱                           │ ← Large Title
│                             │
│ ── 추천 ─────────────────── │
│  ┌──────────┐ ┌──────────┐  │ ← 가로 캐러셀(대형 카드)
│  │ (배너)    │ │ (배너)    │▶ │   CarouselView
│  │ 앱이름    │ │ 앱이름    │  │
│  └──────────┘ └──────────┘  │
│                             │
│ ── 인기 무료 앱    모두 보기 ▶│ ← SectionHeaderView
│  1 ┌──┐ 앱이름       ┌────┐ │ ← ChartRankRow ×N
│    └──┘ 개발사        │받기│ │
│  2 ┌──┐ 앱이름       ┌────┐ │
│  3 ┌──┐ 앱이름       ┌────┐ │
│                             │
│ ── 인기 유료 앱    모두 보기 ▶│
│  1 ┌──┐ 앱이름     ┌──────┐ │
│    └──┘ 개발사      │₩4,400│ │
│                             │
│ ── 카테고리 ──────────────── │
│  ┌─────────┐ ┌─────────┐   │ ← CategoryGridView(정적)
│  │ 🎮 게임  │ │ 📈 생산성 │   │
│  └─────────┘ └─────────┘   │
│         (세로 스크롤)         │
└─────────────────────────────┘
```

## UI 흐름 (버튼 → 동작 → 상태/화면 변화)

```
 화면 진입
   ▼
 loading (섹션 스켈레톤)
   │  LoadAppsFeedUseCase:
   │   ├─(병렬) ITunesClient.chart(.topFree) ─▶ [ChartItem]
   │   ├─(병렬) ITunesClient.chart(.topPaid) ─▶ [ChartItem]
   │   └─ 추천: 정적 큐레이션 ID → ITunesClient.lookup 배치 ─▶ [FeaturedApp]
   ├─ 전체 성공        ─▶ loaded(AppsFeed) — 전 섹션 렌더
   ├─ 일부 실패        ─▶ loaded(AppsFeed) — 성공한 섹션만 렌더(부분 성공)
   └─ 전체 실패        ─▶ failed(msg) — [다시 시도] ─▶ loading 재진입

 loaded 에서
   ├─ [캐러셀 좌우 스와이프]  ─▶ 페이지 전환(상태 변화 없음)
   ├─ [캐러셀 카드 탭]       ─▶ appDetailBuilder.build(appID:) → AppDetail push
   ├─ [차트 행 탭]           ─▶ appDetailBuilder.build(appID:) → AppDetail push
   ├─ [받기/가격 버튼 탭]     ─▶ 버튼 UI 변화만
   ├─ ["모두 보기" 탭]       ─▶ seeAllBuilder.build(input:) → SeeAll push
   │      input = SeeAllInput(title: "인기 무료 앱", feed: .topFree, genreID: nil)
   └─ [카테고리 셀 탭]       ─▶ 동작 없음(UI만 — v1 범위 밖, 확정)
```

## 상태 (ViewModel)
```swift
@Observable @MainActor
final class AppsViewModel {
    enum State { case loading, loaded(AppsFeed), failed(String) }
    private(set) var state: State
    func load() async
}
struct AppsFeed { let featured: [FeaturedApp]; let topFree: [ChartItem]; let topPaid: [ChartItem]; let categories: [Category] }
```

## Domain / Data (피처 소유)
- **엔티티**: `FeaturedApp { id, name, tagline, artworkURL }`, `ChartItem { rank, id, name, artistName, artworkURL, genre }`, `Category { genreID, name, symbol }`(정적 목록).
- **UseCase**: `LoadAppsFeedUseCase` — 차트 2종 병렬 + 추천 큐레이션 Lookup → `AppsFeed` 조립.
- **Repository**: `AppsRepository`(프로토콜) → `DefaultAppsRepository` — `ITunesClient.chart`/`lookup` 사용, DTO → 엔티티 매핑. RSS `rank`는 배열 순서로 부여.

## 네비게이션
- 앱/차트 항목 → 주입받은 `AppDetailBuilder.build(appID:)` 화면을 push.
- "모두 보기" → 주입받은 `SeeAllBuilder.build(input:)` 화면을 push.
- Apps는 `AppDetailInterface`, `SeeAllInterface`만 의존(구현 모름).

## 엣지 케이스
- RSS 두 요청 중 하나 실패 → 성공한 섹션만 표시(부분 성공). 추천 실패 시 추천 섹션만 숨김.
- 이미지 URL 100px만 제공되는 RSS 항목은 그대로 사용.
