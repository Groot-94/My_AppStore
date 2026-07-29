# 피처 · Arcade (아케이드)

## 개요
애플 아케이드 구독 게임 탭. 실제로는 구독 전용 게임 큐레이션.

## 데이터 전략 (중요)
- 아케이드 여부를 API로 직접 필터하기 어렵다 → **정적 큐레이션 목록**(아케이드 게임 `appID` 리스트, `Arcade/Resources/arcade_apps.json`)을 두고 **Lookup API**로 실데이터 채움.
- 상단 히어로 배너/카피는 정적.

## UI 스케치

```
┌─────────────────────────────┐
│ ┌─────────────────────────┐ │
│ │      Apple Arcade        │ │ ← 히어로 배너(정적 카피/이미지)
│ │   한 달 무료 체험         │ │
│ └─────────────────────────┘ │
│                             │
│ ── 새로 추가된 게임 ───────── │
│  ┌─────┐ ┌─────┐ ┌─────┐   │ ← 가로 캐러셀
│  │(아트)│ │(아트)│ │(아트)│ ▶ │   (Lookup 실데이터)
│  │이름  │ │이름  │ │이름  │   │
│  └─────┘ └─────┘ └─────┘   │
│                             │
│ ── 인기 아케이드 게임 ─────── │
│  ┌─────┐ ┌─────┐ ┌─────┐   │
│  └─────┘ └─────┘ └─────┘ ▶ │
│                             │
│ ┌─────────────────────────┐ │
│ │  구독하고 200개+ 게임을   │ │ ← 구독 안내 배너(UI만)
│ │  즐겨보세요               │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

## UI 흐름 (버튼 → 동작 → 상태/화면 변화)

```
 화면 진입
   ▼
 loading (스켈레톤)
   │  LoadArcadeFeedUseCase: arcade_apps.json 로드 → appID 수집 → ITunesClient.lookup 배치 → 섹션 조립
   ├─ 성공 ─▶ loaded(ArcadeFeed) — 히어로(정적) + 캐러셀 2종 렌더
   ├─ 큐레이션 비어있음 ─▶ loaded(빈 피드) — 안내 문구 표시
   └─ 실패(JSON 파싱/Lookup 전체 실패) ─▶ failed(msg) — [다시 시도] ─▶ loading

 loaded 에서
   ├─ [캐러셀 좌우 스와이프] ─▶ 스크롤(상태 변화 없음)
   ├─ [게임 카드 탭]        ─▶ appDetailBuilder.build(appID:) → AppDetail push
   ├─ [히어로 배너 탭]      ─▶ 동작 없음(UI만)
   └─ [구독 배너 탭]        ─▶ 동작 없음(UI만 — 결제는 Out of Scope)
```

## 상태 (ViewModel)
```swift
@Observable @MainActor
final class ArcadeViewModel {
    enum State { case loading, loaded(ArcadeFeed), failed(String) }
    private(set) var state: State
    func load() async
}
```

## Domain / Data (피처 소유)
- **엔티티**: `ArcadeFeed { hero(정적), newGames: [ArcadeGame], popular: [ArcadeGame] }`, `ArcadeGame { id, name, genre, artworkURL }`.
- **UseCase**: `LoadArcadeFeedUseCase` — 정적 큐레이션 로드 → 참조 앱 ID Lookup 배치 → 섹션 조립.
- **Repository/DataSource**: `ArcadeCurationDataSource`(로컬 JSON) + `ArcadeRepository` → `DefaultArcadeRepository`(`ITunesClient.lookup`, DTO → `ArcadeGame` 매핑).

## 네비게이션
- 게임 카드 → 주입받은 `AppDetailBuilder.build(appID:)` 화면을 push. (`AppDetailInterface`만 의존.)

## 엣지 케이스
- Lookup 실패 항목 제외(부분 실패 허용). 큐레이션 비어있으면 안내 문구.
