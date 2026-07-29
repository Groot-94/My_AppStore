# 08. 동작 흐름 다이어그램

풀 모듈러 아키텍처(피처당 `Interface`/`Implementation`/`Testing`/`Example` 타깃 분리) 기준으로,
모듈 의존 관계와 각 피처의 런타임 동작 흐름을 텍스트 그림으로 정리한다.
버튼 단위의 상세 UI 흐름은 각 피처 문서([05-features/](05-features/))의 "UI 흐름" 절에 있다.

> 원칙: **구현이 아니라 계약(Interface)에 의존.** 피처끼리는 상대 피처의 `*Interface`만 안다.
> 실제 구현체 조립은 App(Composition Root)에서만 이뤄진다. 엔티티는 피처가 소유한다(공용 Domain 없음).

---

## 1. 모듈 그래프 (풀 모듈러)

```
                          ┌───────────────────────────┐
                          │          AppUIKit          │  Composition Root
                          │  (모든 Impl + Interface 조립) │  ← 유일하게 전부 앎
                          └─────────────┬─────────────┘
                                        │ 구현체 주입 / DI 등록 / Builder 계약 조립
        ┌───────────────┬──────────────┼──────────────┬───────────────┐
        ▼               ▼              ▼               ▼               ▼
 ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐
 │  Search    │  │  Today     │  │  Apps/Games│  │  Arcade    │  │ AppDetail/ │  ← Implementation
 │ (Impl)     │  │ (Impl)     │  │ (Impl)     │  │ (Impl)     │  │ SeeAll     │
 └─────┬──────┘  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘
       │  implements    │               │               │               │
       ▼                ▼               ▼               ▼               ▼
 ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐
 │SearchIntf  │  │TodayIntf   │  │AppsIntf …  │  │ArcadeIntf  │  │AppDetailIntf│ ← Interface(계약)
 └─────┬──────┘  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘  │SeeAllIntf  │
       │                │               │               │        └─────┬──────┘
       └────────────────┴───── 피처끼리는 여기(Interface)만 참조 ──┴──────┘
                                        │
                ┌───────────────┬───────┴──────┬───────────────┐
                ▼               ▼              ▼               ▼
         ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐
         │ ITunesKit  │  │ Networking │  │Persistence │  │DesignSystem│  ← Core
         │(공용 DTO +  │─▶│(NetClient) │  │(Cache/이미지)│  │ (UIKit UI) │
         │ITunesClient)│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘
         └─────┬──────┘        │               │               │
               └───────────────┴───────────────┴──── CoreKit ──┘
                       (DI, StoreConfig, 로거 — UI/네트워크 비의존)

의존 방향: App ─▶ Impl ─▶ (자기 Interface + ITunesKit + DesignSystem) ─▶ CoreKit
피처 A ─▶ 피처 B 는 오직 BInterface 로만. (역방향·순환 금지 → `tuist graph`로 검증)
엔티티/UseCase/Repository 프로토콜은 각 피처 Impl 내부(Domain 폴더)가 소유.
```

타깃 종류(피처마다 동일 패턴):

```
Feature/Search/
├─ SearchInterface   프로토콜·진입 계약만. UIKit 최소. 거의 안 바뀜 → 캐시 적중↑
├─ Search            실제 구현. Interface를 implements. App만 참조.
├─ SearchTesting     Mock/Stub. Interface에만 의존. 타 피처 테스트에서 주입.
└─ SearchExample     단독 실행 데모 앱. 피처 격리 개발/스크린샷용.
```

---

## 2. 피처 간 연동 (계약 주입 방식)

god-router 대신, 각 피처가 자기 진입 계약을 `Interface`로 노출하고 App이 조합한다.

```
 ┌────────────────────────────────────────────────────────────────┐
 │  AppUIKit (Composition Root)                                     │
 │                                                                  │
 │   let appDetail = DefaultAppDetailBuilder(...)   // 구현 생성      │
 │   let search    = DefaultSearchBuilder(                           │
 │                       appDetailBuilder: appDetail )  // 계약 주입 │
 └────────────────────────────────────────────────────────────────┘
                       │ 주입되는 것은 "계약"
                       ▼
   SearchViewModel ──▶ appDetailBuilder: AppDetailBuilder   (AppDetailInterface)
        │                        │
        │ 항목 탭                 └─▶ .build(appID:) -> UIViewController
        ▼
   push AppDetail 화면   ← Search는 AppDetail "구현"을 전혀 모름
```

계약 예시:

```swift
// AppDetailInterface — 다른 피처/App이 보는 유일한 표면
public protocol AppDetailBuilder {
    func build(appID: Int) -> UIViewController
}
// Search (구현)는 위 프로토콜 타입만 주입받는다 → 순환 0, 타입 안전

// SeeAllInterface — 파라미터 타입도 Interface가 소유
public protocol SeeAllBuilder {
    func build(input: SeeAllInput) -> UIViewController   // title + feed + genreID
}
```

---

## 3. 계층 데이터 흐름 (모든 피처 공통 골격)

```
 [사용자 행동]
      │
      ▼
 ┌──────────────┐   관찰(@Observable)   ┌──────────────┐
 │  View        │◀──────────────────────│  ViewModel   │  @MainActor
 │ (UIKit/SwiftUI)│      state 갱신       │  state: enum │
 └──────┬───────┘                        └──────┬───────┘
        │ 행동 호출                              │ execute()
        │                                        ▼
        │                                 ┌──────────────┐
        │                                 │  UseCase     │  피처 Domain (순수 Swift)
        │                                 └──────┬───────┘
        │                                        │ 프로토콜 호출
        │                                        ▼
        │                                 ┌──────────────┐
        │                                 │ Repository   │  ← 프로토콜(피처 Domain)
        │                                 │ (프로토콜)    │     구현은 피처 Data 폴더
        │                                 └──────┬───────┘
        │                              구현 주입   │  DTO → 피처 엔티티 매핑(Mapper)
        │                                        ▼
        │                        ┌───────────────────────────────┐
        │                        │ DataSource                    │
        │                        │  ITunesKit(ITunesClient) /    │
        │                        │  Persistence(Cache) / 로컬 JSON │
        │                        └───────────────────────────────┘

 async/await 단방향. Combine 미사용. Repository/DataSource는 Sendable.
```

---

## 4. 피처별 동작 흐름

### 4.1 Search (검색)

```
검색어 입력 + Return
      │
      ▼
SearchView ──▶ SearchViewModel.search(term)
                    │  state = .loading
                    ▼
              SearchAppsUseCase.execute(term)
                    │  ├─ 트림/빈값 검증 (빈값이면 .idle 유지, 호출 안 함)
                    │  └─ RecentSearchStore 저장 (Persistence)
                    ▼
              SearchRepository.search(term)          [프로토콜, 피처 Domain]
                    ▼
              DefaultSearchRepository                [피처 Data]
                    ▼
              ITunesClient.search ─GET─▶ iTunes Search API
                    │                    (entity=software, country, limit=25)
                    ▼
              [ITunesAppDTO] ──Mapper──▶ [SearchResultItem]
                    ▼
   ┌────────────────┼─────────────────┬──────────────────┐
   ▼                ▼                  ▼                  ▼
결과 있음        결과 0건            네트워크 실패        (입력 대기)
state=.loaded    state=.empty(term)  state=.failed(msg)  state=.idle([최근검색어])
   │
   ▼
항목 탭 ──▶ appDetailBuilder.build(appID:) ──▶ AppDetail push

엣지: 연속 입력 시 이전 Task 취소(최신 요청만 반영).
```

### 4.2 Today (에디터 큐레이션)

```
화면 진입 / Pull-to-refresh
      │  state = .loading
      ▼
TodayViewModel.load()
      ▼
LoadTodayFeedUseCase.execute()
      │
      ├─▶ TodayCurationDataSource ─load─▶ today_curation.json (로컬 정적)
      │        └─ 스토리 메타(제목/부제/카피/커버) + 참조 appID[] 추출
      │
      └─▶ TodayRepository.lookup(ids) ─ITunesClient─▶ iTunes Lookup API (배치)
               └─ [TodayAppSummary] (아이콘/이름 실데이터)
      │
      ▼
 큐레이션 메타 ⨝ [TodayAppSummary]  ──조립──▶ [TodayCard]
      │
      ▼
state = .loaded([TodayCard])   또는   .failed(msg)(JSON 파싱 실패 시)
      │
      ▼
카드 탭 ──▶ appDetailBuilder.build(appID:) ──▶ AppDetail

엣지: Lookup 실패한 앱은 카드에서 제외(부분 실패 허용).
```

### 4.3 Apps / Games (둘러보기)

```
화면 진입
      │  state = .loading
      ▼
AppsViewModel.load()   (Games: GamesViewModel — 차트에 genres "Games" 필터 추가)
      ▼
LoadAppsFeedUseCase.execute()
      │
      ├──(병렬)──▶ AppsRepository.chart(.topFree) ─RSS─▶ [ChartItem]
      ├──(병렬)──▶ AppsRepository.chart(.topPaid) ─RSS─▶ [ChartItem]
      └──────────▶ 추천 캐러셀: 정적 큐레이션 ID → ITunesClient.lookup 배치 → [FeaturedApp]
      │
      ▼
 AppsFeed{ featured, topFree, topPaid, categories(정적 Category) }
      │
      ▼
state = .loaded(AppsFeed)   또는   .failed(msg)
   (RSS 두 요청 중 하나만 실패 → 성공 섹션만 표시, 부분 성공)
      │
      ├─ 항목 탭         ──▶ appDetailBuilder.build(appID:) ──▶ AppDetail
      └─ "모두 보기" 탭  ──▶ seeAllBuilder.build(input:)    ──▶ SeeAll 목록
                              (Games는 input.genreID = 6014)

Games 는 Apps 와 동형 — 레이아웃/셀 공통(DesignSystem), 데이터 필터만 게임으로 주입.
```

### 4.4 Arcade (아케이드)

```
화면 진입
      │  state = .loading
      ▼
ArcadeViewModel.load()
      ▼
LoadArcadeFeedUseCase.execute()
      │
      ├─▶ ArcadeCurationDataSource ─load─▶ arcade_apps.json (로컬 정적 appID 리스트 + 히어로 카피)
      │
      └─▶ ArcadeRepository.lookup(ids) ─ITunesClient─▶ iTunes Lookup API (배치)
               └─ [ArcadeGame]
      │
      ▼
 히어로 배너(정적) + [섹션: 새로 추가 / 인기 아케이드] 조립
      │
      ▼
state = .loaded(ArcadeFeed)  또는  .failed / 빈 큐레이션 → 안내 문구
      │
      ▼
게임 카드 탭 ──▶ appDetailBuilder.build(appID:) ──▶ AppDetail

엣지: Lookup 실패 항목 제외. 구독 배너는 UI만(동작 없음).
```

### 4.5 AppDetail (앱 상세) — 공통 진입점

```
어느 피처든 항목 탭
      │  appDetailBuilder.build(appID:) 로 생성/푸시
      ▼
AppDetailViewModel(appID).load()
      │  state = .loading
      ▼
LoadAppDetailUseCase.execute(appID)
      ▼
AppDetailRepository.fetch(id)
      │  ├─ Persistence.Cache 우선 조회 ── hit ─▶ 캐시 반환
      │  └─ miss ─▶ ITunesClient.lookup(id) ─▶ 캐시 저장
      ▼
ITunesAppDTO ──Mapper──▶ AppDetail(엔티티)
      │
   ┌──┴───────────────┐
   ▼                  ▼
결과 1건            결과 0건 (삭제/미출시)
state=.loaded(AppDetail)  state=.failed("앱을 찾을 수 없음")
   │
   ▼
렌더: 헤더 · 메타 스트립 · 스크린샷 페이저(없으면 섹션 숨김)
      · 설명(더 보기) · 새로운 기능 · 정보 테이블

헤더/받기 버튼/스크린샷 페이저/평점 = DesignSystem 공통 컴포넌트(목록 셀과 일관).
```

### 4.6 SeeAll (모두 보기)

```
Apps/Games "모두 보기" 탭
      │  seeAllBuilder.build(input:) 로 생성/푸시   input = (title, feed, genreID?)
      ▼
SeeAllViewModel(input).load()
      │  state = .loading
      ▼
LoadChartUseCase.execute(input)
      ▼
ChartRepository.chart(feed, limit: 50) ─ITunesClient─▶ RSS
      │  └─ genreID 있으면 genres 필터 + rank 재부여
      ▼
[RSSEntryDTO] ──Mapper──▶ [SeeAllItem]
      │
      ▼
state = .loaded([SeeAllItem])  또는  .failed(msg)
      │
      ▼
행 탭 ──▶ appDetailBuilder.build(appID:) ──▶ AppDetail push
```

---

## 5. 탭 조립 & 부팅 흐름 (App)

```
앱 시작 (SceneDelegate)
      │
      ▼
DIContainer 구성
   ├─ NetworkClient(URLSession) 등록
   ├─ ITunesClient(DefaultITunesClient) 등록
   ├─ Cache / ImageLoading 등록
   └─ StoreConfig(country: "kr", lang: "ko_kr") 등록
      │
      ▼
각 피처 Builder 생성 (구현체) + 상호 계약 주입
   AppDetailBuilder ─▶ (Search/Today/Apps/Games/Arcade/SeeAll 에 주입)
   SeeAllBuilder    ─▶ (Apps/Games 에 주입)
      │
      ▼
UITabBarController 조립
   [ Today | Games | Apps | Arcade | Search ]  ← 각 탭 = 피처 Builder.build()
      │
      ▼
window.rootViewController = tabBar → 실행
```
