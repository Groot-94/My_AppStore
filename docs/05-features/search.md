# 피처 · Search (검색)

## 개요
키워드로 앱을 검색해 목록으로 보여주고, 항목 선택 시 상세로 이동. iTunes Search API와 직결되는 핵심 피처.

## UI 스케치

```
 [대기 idle]                          [로딩 loading]
┌─────────────────────────┐      ┌─────────────────────────┐
│ 검색                     │      │ ┌─────────────────────┐ │
│ ┌─────────────────────┐ │      │ │ 🔍 카카오        ✕  │ │
│ │ 🔍 게임, 앱, 스토리 등│ │      │ └─────────────────────┘ │
│ └─────────────────────┘ │      │ ▒▒▒▒▒▒▒▒▒▒  ▒▒▒        │
│                         │      │ ▒▒▒▒▒▒▒▒▒▒  ▒▒▒        │ ← 스켈레톤
│ 최근 검색어        지우기 │      │ ▒▒▒▒▒▒▒▒▒▒  ▒▒▒        │
│  카카오톡                │      └─────────────────────────┘
│  지도                    │
│  날씨                    │       [결과 loaded]
└─────────────────────────┘      ┌─────────────────────────┐
                                 │ ┌──┐ 카카오톡      ┌────┐│
 [결과 없음 empty]                │ │🟨│ 카카오        │받기││
┌─────────────────────────┐      │ └──┘ ★4.1 · 소셜   └────┘│
│                         │      │ ┌──┐ 카카오맵      ┌────┐│
│  "xyz"에 대한 결과 없음   │      │ │🟦│ 카카오        │받기││
│                         │      │ └──┘ ★4.5 · 내비   └────┘│
└─────────────────────────┘      │        (세로 스크롤)      │
                                 └─────────────────────────┘
 [실패 failed]
┌─────────────────────────┐
│   불러올 수 없음          │
│   네트워크를 확인하세요    │
│      [다시 시도]          │
└─────────────────────────┘
```

- 검색바: `UISearchController`. 결과 행: `DesignSystem.AppRowCell`(아이콘·이름·개발사·평점·장르·받기).

## UI 흐름 (버튼 → 동작 → 상태/화면 변화)

```
                    [✕ / 취소 탭] ── 입력·결과 초기화 ──┐
        ┌─────────────────────────────────────────────┘
        ▼
 idle(최근 검색어 표시)
   │
   ├─ [최근 검색어 행 탭] ─▶ 검색바에 term 채움 + 즉시 검색 실행 (loading 진입)
   ├─ [지우기 탭] ─▶ RecentSearchStore 비움 ─▶ idle([]) — 최근 검색어 섹션 숨김
   │
   └─ [검색어 입력 + Return]
        │  트림 후 빈 문자열이면 무시(idle 유지)
        ▼
     loading (스켈레톤)  ← 연속 Return 시 이전 검색 Task 취소, 최신 요청만 반영
        │  SearchAppsUseCase → SearchRepository → ITunesClient.search
        ├─ 성공(1건 이상) ─▶ loaded([SearchResultItem]) — 결과 리스트 렌더
        │     ├─ [결과 행 탭]  ─▶ appDetailBuilder.build(appID:) → AppDetail push
        │     └─ [받기 버튼 탭] ─▶ 버튼 UI 변화만(다운로드 없음)
        ├─ 0건 ─▶ empty(term) — "'{term}'에 대한 결과 없음"
        └─ 실패 ─▶ failed(msg) — [다시 시도 탭] ─▶ 직전 term으로 loading 재진입
```

## 상태 (ViewModel)
```swift
@Observable @MainActor
final class SearchViewModel {
    enum State { case idle([String]), loading, loaded([SearchResultItem]), empty(String), failed(String) }
    private(set) var state: State
    func search(term: String) async
    func selectRecent(_ term: String) async
    func clearRecents()
}
```
- `idle`은 최근 검색어 배열을 동반.
- 검색 실행은 **검색 버튼 클릭/Return** 기준(자동완성은 범위 밖, 후속 옵션).

## Domain / Data (피처 소유)
- **엔티티**: `SearchResultItem { id, name, sellerName, genre, iconURL, rating, ratingCount, priceText }` — 목록 표시용 필드만.
- **UseCase**: `SearchAppsUseCase` — `func execute(term: String) async throws -> [SearchResultItem]`. 검색어 트림/빈값 검증, 최근 검색어 저장(`RecentSearchStore`) 위임.
- **Repository**: `SearchRepository`(프로토콜, Domain) → `DefaultSearchRepository`(Data) — `ITunesClient.search(term:genreID:limit:)` 호출 후 DTO → `SearchResultItem` 매핑.

## 네비게이션
- 항목 선택 → 주입받은 `AppDetailBuilder.build(appID:)` 화면을 push. (Search는 `AppDetailInterface`만 의존.)

## 엣지 케이스
- 공백/빈 검색어: 검색 안 함, `idle` 유지.
- 연속 입력: 이전 검색 `Task` 취소(최신 요청만 반영).
- 중복 최근 검색어: 최상단으로 갱신, **최대 10개** 유지.
