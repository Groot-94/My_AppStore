# 피처 · Today

## 개요
에디터 큐레이션 피드. 실제 App Store의 첫 탭. 큰 카드 형태의 스토리들을 세로로 스크롤.

## 데이터 전략 (중요)
- 에디터 스토리(제목/부제/카피/커버 이미지)는 **API에 없음** → 앱 내 **정적 큐레이션 JSON**으로 구성(`Today/Resources/today_curation.json`).
- 각 스토리는 `appID`(들)를 참조 → 실제 앱 정보(아이콘/이름/설명)는 **Lookup API**로 채움.
- 즉 "큐레이션 틀(정적) + 앱 실데이터(API)" 하이브리드.

## UI 스케치

```
┌─────────────────────────────┐
│ 7월 29일 화요일          (👤) │ ← 날짜 헤더 + 프로필(UI만)
│ 투데이                       │ ← Large Title
│                             │
│ ┌─────────────────────────┐ │
│ │                         │ │
│ │      (커버 이미지)        │ │ ← 대형 피처 카드
│ │  오늘의 앱                │ │   (정적 카피 + 커버)
│ │  집중력을 높이는 방법      │ │
│ │ ┌──┐ 앱이름       ┌────┐ │ │
│ │ │📱│ 부제         │받기│ │ │ ← 참조 앱(Lookup 실데이터)
│ │ └──┘              └────┘ │ │
│ └─────────────────────────┘ │
│                             │
│ ┌─────────────────────────┐ │
│ │ 추천 모음 (리스트형 카드)  │ │
│ │ ┌──┐ 앱1          ┌────┐ │ │
│ │ └──┘ 부제          │받기│ │ │
│ │ ┌──┐ 앱2          ┌────┐ │ │
│ │ └──┘ 부제          │받기│ │ │
│ └─────────────────────────┘ │
│         (세로 스크롤)         │
└─────────────────────────────┘
```

- 카드 유형: 대형 피처 카드 / 앱·게임 오브 더 데이 / 리스트형 카드(추천 앱 여러 개).

## UI 흐름 (버튼 → 동작 → 상태/화면 변화)

```
 화면 진입
   ▼
 loading (스켈레톤 카드)
   │  LoadTodayFeedUseCase: 정적 JSON 로드 → 참조 appID 수집 → ITunesClient.lookup 배치 → 카드 조립
   ├─ 성공 ─▶ loaded([TodayCard]) — 카드 렌더
   └─ 실패(JSON 파싱 실패 / Lookup 전체 실패) ─▶ failed(msg) — [다시 시도] ─▶ loading 재진입

 loaded 에서
   ├─ [대형 카드 탭]        ─▶ 카드의 대표 앱 AppDetail push
   │                          (스토리 전문 화면은 Out of Scope — 확정)
   ├─ [카드 내 앱 행 탭]     ─▶ appDetailBuilder.build(appID:) → AppDetail push
   ├─ [받기 버튼 탭]        ─▶ 버튼 UI 변화만(다운로드 없음)
   ├─ [(👤) 프로필 탭]      ─▶ 동작 없음(UI만, Out of Scope)
   └─ [Pull-to-refresh]    ─▶ 기존 카드 유지한 채 refresh() → 완료 시 loaded 교체
                              (실패 시 기존 카드 유지 + 토스트/무시)
```

## 상태 (ViewModel)
```swift
@Observable @MainActor
final class TodayViewModel {
    enum State { case loading, loaded([TodayCard]), failed(String) }
    private(set) var state: State
    func load() async
    func refresh() async   // Pull to refresh
}
```

## Domain / Data (피처 소유)
- **엔티티**: `TodayCard`(카드 유형 + 큐레이션 메타 + `[TodayAppSummary]`), `TodayAppSummary { id, name, genre, iconURL, priceText }`.
- **UseCase**: `LoadTodayFeedUseCase` — 정적 큐레이션 로드 + 참조 앱 ID Lookup 배치 → `TodayCard` 조립.
- **Repository/DataSource**: `TodayCurationDataSource`(로컬 JSON) + `TodayRepository`(프로토콜) → `DefaultTodayRepository`(`ITunesClient.lookup` 사용, DTO → `TodayAppSummary` 매핑).

## 네비게이션
- 앱 카드 → 주입받은 `AppDetailBuilder.build(appID:)` 화면을 push. (`AppDetailInterface`만 의존.)

## 엣지 케이스
- Lookup 실패한 앱은 카드에서 제외(부분 실패 허용). 참조 앱이 전부 실패한 카드는 카드째 제외.
- 큐레이션 JSON 파싱 실패 → 에러 상태.
