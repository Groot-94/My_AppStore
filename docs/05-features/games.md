# 피처 · Games (게임)

## 개요
게임 전용 둘러보기 탭. 구조는 **Apps 탭과 동형**이되 데이터가 게임으로 한정된다.

## 데이터 전략 (확정)
- **차트(무료/유료 게임)**: RSS에 게임 전용 피드가 없으므로, `ITunesClient.chart` 결과에서 `genres`에 "Games" 포함 항목을 **필터**해 사용.
- **추천 캐러셀**: 정적 큐레이션 ID + Lookup 배치(Apps와 동일 패턴).
- **하위 카테고리 그리드**: 정적 목록(액션/퍼즐/RPG 등, genreID 보유). 탭 동작은 v1 범위 밖.
- Search `genreId=6014` 활용은 후속 옵션(카테고리 탭 동작 붙일 때).

## UI 스케치

```
┌─────────────────────────────┐
│ 게임                         │ ← Large Title
│                             │
│ ── 추천 게임 ─────────────── │
│  ┌──────────┐ ┌──────────┐  │ ← 가로 캐러셀
│  │ (배너)    │ │ (배너)    │▶ │
│  └──────────┘ └──────────┘  │
│                             │
│ ── 인기 무료 게임  모두 보기 ▶│
│  1 ┌──┐ 게임이름      ┌────┐ │
│  2 ┌──┐ 게임이름      │받기│ │
│  3 ┌──┐ 게임이름      └────┘ │
│                             │
│ ── 인기 유료 게임  모두 보기 ▶│
│  1 ┌──┐ 게임이름   ┌──────┐ │
│                    │₩6,600│ │
│ ── 카테고리 ──────────────── │
│  ┌─────────┐ ┌─────────┐   │
│  │ ⚔️ 액션  │ │ 🧩 퍼즐  │   │
│  └─────────┘ └─────────┘   │
└─────────────────────────────┘
```

레이아웃·셀은 전부 Apps와 동일한 DesignSystem 스토어 피드 컴포넌트를 재사용한다.

## UI 흐름 (버튼 → 동작 → 상태/화면 변화)

Apps와 동형. 차이는 데이터 필터와 SeeAll 입력뿐.

```
 화면 진입 ─▶ loading
   │  LoadGamesFeedUseCase:
   │   ├─(병렬) chart(.topFree) → genres "Games" 필터 ─▶ [ChartItem]
   │   ├─(병렬) chart(.topPaid) → genres "Games" 필터 ─▶ [ChartItem]
   │   └─ 추천: 정적 큐레이션 ID → lookup 배치 ─▶ [FeaturedApp]
   ├─ 성공/부분 성공 ─▶ loaded(GamesFeed)
   └─ 전체 실패 ─▶ failed — [다시 시도] ─▶ loading

 loaded 에서
   ├─ [캐러셀 카드/차트 행 탭] ─▶ AppDetail push
   ├─ ["모두 보기" 탭] ─▶ seeAllBuilder.build(input:) → SeeAll push
   │      input = SeeAllInput(title: "인기 무료 게임", feed: .topFree, genreID: 6014)
   │      (SeeAll이 동일한 게임 필터를 적용)
   └─ [카테고리 셀 탭] ─▶ 동작 없음(UI만 — v1 범위 밖, 확정)
```

## 상태 / Domain / Data (피처 소유)
- `GamesViewModel` — Apps와 동형(`GamesFeed`).
- **엔티티**: `FeaturedApp` / `ChartItem` / `Category` — Games 피처가 자체 소유(Apps와 이름이 같아도 별개 타입. 피처 간 공유 금지 원칙).
- **UseCase**: `LoadGamesFeedUseCase` — 게임 필터 반영.
- **Repository**: `GamesRepository` → `DefaultGamesRepository`(`ITunesClient.chart`/`lookup` + 게임 필터).

## 공통화 메모
- Apps/Games는 레이아웃·상태·셀이 거의 동일 → **DesignSystem의 스토어 피드 컴포넌트**를 재사용하고, 피처는 데이터 소스만 다르게 주입(중복 최소화).
- 공통 화면을 별도 피처로 빼지 않는다(피처 간 import 금지 원칙 유지).

## 네비게이션
- 앱/차트 항목 → 주입받은 `AppDetailBuilder.build(appID:)` 화면을 push.
- "모두 보기" → 주입받은 `SeeAllBuilder.build(input:)` 화면을 push (genreID: 6014).
- Games는 `AppDetailInterface`, `SeeAllInterface`만 의존(Apps와 동형).

## 엣지 케이스
- 게임 필터 후 항목이 지나치게 적으면(차트에 게임이 적은 경우) 있는 만큼만 표시.
- RSS 부분 실패 → 성공 섹션만 표시.
