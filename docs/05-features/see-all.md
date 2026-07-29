# 피처 · SeeAll (모두 보기)

## 개요
Apps/Games 탭의 차트 섹션 헤더 "모두 보기"가 이동하는 **차트 전체 목록 화면**. 독립 피처로 소유하여 Apps/Games가 서로를 몰라도 같은 화면을 재사용한다.

## 진입
- 입력: `SeeAllInput(title:feed:genreID:)` — `SeeAllInterface`가 타입을 소유.
  - `title`: 내비게이션 타이틀(예: "인기 무료 앱").
  - `feed`: `.topFree` / `.topPaid`.
  - `genreID`: `nil`(전체) 또는 `6014`(게임 — Games 탭에서 진입 시).
- `SeeAllBuilder.build(input:)`로 생성. Apps/Games는 이 계약만 주입받아 push.

## UI 스케치

```
┌─────────────────────────────┐
│ ◀ 앱          인기 무료 앱   │ ← SeeAllInput.title
│                             │
│  1 ┌──┐ 앱이름        ┌────┐│ ← ChartRankRow ×N
│    └──┘ 개발사 · 장르  │받기││   (Apps 차트와 동일 셀)
│  2 ┌──┐ 앱이름        ┌────┐│
│    └──┘ 개발사 · 장르  │받기││
│  3 ┌──┐ 앱이름        ┌────┐│
│  ⋮                          │
│ 50 ┌──┐ 앱이름        ┌────┐│
│         (세로 스크롤)        │
└─────────────────────────────┘
```

## UI 흐름 (버튼 → 동작 → 상태/화면 변화)

```
 Apps/Games에서 ["모두 보기" 탭] → build(input:) 로 생성·push
   ▼
 loading (스켈레톤 행)
   │  LoadChartUseCase → ChartRepository → ITunesClient.chart(feed, limit: 50)
   │   └─ input.genreID 있으면 genres 필터 적용 + rank 재부여
   ├─ 성공 ─▶ loaded([SeeAllItem]) — 순위 목록 렌더
   └─ 실패 ─▶ failed(msg) — [다시 시도] ─▶ loading 재진입

 loaded 에서
   ├─ [행 탭]        ─▶ appDetailBuilder.build(appID:) → AppDetail push
   ├─ [받기 버튼 탭]  ─▶ 버튼 UI 변화만
   └─ [◀ back]      ─▶ Apps/Games로 pop
```

## 상태 (ViewModel)
```swift
@Observable @MainActor
final class SeeAllViewModel {
    enum State { case loading, loaded([SeeAllItem]), failed(String) }
    private(set) var state: State
    let input: SeeAllInput
    func load() async
}
```

## Domain / Data (피처 소유)
- **엔티티**: `SeeAllItem { rank, id, name, artistName, artworkURL, genre }`.
- **UseCase**: `LoadChartUseCase` — feed 조회 + (필요 시) 장르 필터 + rank 부여.
- **Repository**: `ChartRepository`(프로토콜) → `DefaultChartRepository`(`ITunesClient.chart`, DTO → `SeeAllItem` 매핑).

## 네비게이션
- 항목 탭 → 주입받은 `AppDetailBuilder.build(appID:)` 화면을 push. (SeeAll은 `AppDetailInterface`만 의존.)

## 엣지 케이스
- 장르 필터 후 항목이 적으면 있는 만큼만 표시(빈 결과면 안내 문구).
- RSS 항목은 아이콘 100px만 제공 → 그대로 사용(Lookup 보강은 후속 옵션).
