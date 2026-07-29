# 02. 아키텍처

## 큰 그림

이 프로젝트의 목표는 **대규모 모듈러 아키텍처의 정석**을 보여주는 것이다.
따라서 "피처당 1 프레임워크"가 아니라, **피처당 여러 타깃**(Interface/Implementation/Testing/Example)으로
쪼개고, **구현이 아니라 계약(Interface)에 의존**하는 구조를 채택한다.

```
┌─────────────────────────────────────────────────────────────┐
│  App (Composition Root)                                       │
│  ├─ AppUIKit    : TabBar 조립 + DI 등록 + Builder 계약 조립    │  ← 먼저
│  └─ AppSwiftUI  : SwiftUI 조립 (동일 ViewModel 재사용)         │  ← 나중
│  * App만 모든 Implementation을 안다.                           │
└───────────────┬───────────────────────────────────────────────┘
                │ 구현체 생성 · 계약 주입 · DI 등록
┌───────────────▼───────────────────────────────────────────────┐
│  Feature Implementation (Search·Today·Apps·Games·Arcade·        │
│                          AppDetail·SeeAll)                      │
│  각 Impl 은 자기 Interface 를 implements. App만 참조.            │
│  Domain(엔티티·UseCase)·Data(매핑)·Presentation을 피처가 소유.    │
└───────────────┬───────────────────────────────────────────────┘
                │ implements ▲ 피처끼리는 여기(Interface)만 참조
┌───────────────▼───────────────────────────────────────────────┐
│  Feature Interface (SearchInterface · AppDetailInterface · …)   │
│  진입 Builder 계약 + 피처 공개 타입. 거의 안 바뀜(빌드 캐시↑).    │
└───────────────┬───────────────────────────────────────────────┘
                │ 의존
┌───────────────▼───────────────────────────────────────────────┐
│  Core (공통)                                                    │
│  CoreKit · Networking · Persistence · ITunesKit · DesignSystem  │
└─────────────────────────────────────────────────────────────────┘
```

## 의존 규칙 (Dependency Rule)

1. **위 → 아래로만** 의존한다. App → Impl → Interface → Core. 역방향 금지.
2. **피처는 다른 피처의 구현을 import 하지 않는다.** 다른 피처가 필요하면 그 피처의
   **`*Interface`(진입 Builder 계약)** 만 의존하고, 실제 구현체는 App이 주입한다.
3. **`*Interface`는 가볍게 유지**한다. CoreKit + (필요 시) UIKit에만 의존.
   계약에 필요한 공개 타입(`SeeAllInput` 등)은 **Interface가 직접 소유**한다.
   ITunesKit/Networking/Persistence/타 피처 구현에는 의존하지 않는다.
4. **Core 안에서**: `DesignSystem`만 UIKit에 의존. `CoreKit`/`Networking`/`Persistence`/`ITunesKit`은 UI 프레임워크 비의존.
5. **피처 내부**: Presentation → Domain ← Data. Domain은 아무것도 의존하지 않는다(순수 Swift).
6. 순환 의존 금지 — `tuist graph`를 CI에서 돌려 Interface→Impl 역참조·주기를 자동 차단.

## 공용 Domain 모듈을 두지 않는 이유 (확정)

피처 간 계약이 `build(appID: Int)`처럼 **원시 타입만 주고받으므로**, 엔티티가 피처 경계를 넘을 일이 없다.
공용 `AppItem` 같은 엔티티 모듈을 두면:

1. **전 피처가 한 모듈에 결합** — 필드 하나 변경에 모든 피처가 리빌드되어, Interface 분리로 얻은 빌드 캐시 이점이 상쇄된다.
2. **화면별 과잉 스펙** — 목록 화면(Search)이 상세 전용 필드(description/fileSizeBytes)까지 알게 된다.

따라서:

- **엔티티·UseCase·Repository 프로토콜은 전부 피처의 Domain 폴더가 소유**한다. 각 화면이 필요한 필드만 갖는다.
- 전 피처가 똑같이 반복할 수밖에 없는 **iTunes 응답 디코딩(DTO)과 API 호출만 `ITunesKit`(Core)으로 공용화**한다.
- 각 피처의 Data/Mapper가 "공용 DTO → 자기 엔티티" 변환을 담당한다(→ [04-data-api](04-data-api.md)).
- DesignSystem도 엔티티를 모른다 — 컴포넌트는 원시 값/자체 구성 모델(`AppRowCell.Model` 등)로 입력받는다.

## 피처 타깃 구성 (풀 모듈러)

피처마다 동일한 4종 타깃 패턴을 따른다.

```
Feature/Search/
├─ SearchInterface    진입 Builder 계약 + 공개 타입만. 다른 피처/App이 보는 유일한 표면.
├─ Search             실제 구현(Domain/Data/Presentation 폴더). Interface를 implements. App만 참조.
├─ SearchTesting      Mock/Stub. Interface에만 의존. 타 피처·App 테스트에서 주입.
└─ SearchExample      단독 실행 데모 앱. 피처 격리 개발/스크린샷용(선택).
```

> `Testing`/`Example`은 쇼케이스 완성도를 위해 최소 1~2개 피처(Search, AppDetail)부터 포함하고
> 점진 확장한다. 골격 단계(M0)에서는 `Interface` + `Implementation` 2타깃으로 시작한다.

## 피처 내부 구조 (클린 아키텍처, 폴더로 분리)

`Search`(Implementation) 타깃 내부를 3계층 폴더로 나눈다.

```
Features/Search/Sources/
├─ Domain/
│   ├─ Entity/          SearchResultItem 등 — 피처 소유, 화면에 필요한 필드만
│   ├─ UseCase/         SearchAppsUseCase (프로토콜 + 구현)
│   └─ Repository/      SearchRepository (프로토콜, 인터페이스만)
├─ Data/
│   ├─ Mapper/          ITunesKit DTO → 피처 엔티티 변환
│   └─ Repository/      DefaultSearchRepository (ITunesKit의 ITunesClient 사용)
└─ Presentation/
    ├─ ViewModel/       SearchViewModel (@Observable, @MainActor)
    ├─ View/            SearchViewController (UIKit)
    └─ Builder/         DefaultSearchBuilder (SearchInterface.SearchBuilder 구현)
```

**계층 경계는 접근 제어 + 컨벤션으로 강제** (같은 타깃 내부이므로 컴파일러 강제는 아님):
- Domain은 `import UIKit`/`import ITunesKit`/`import Networking` 금지 (Repository는 프로토콜만).
- Presentation은 Data를 직접 참조하지 않는다. UseCase(Domain)만 호출.
- 조립(Repository 구현 주입)은 피처의 **Builder**에서 수행.

## 데이터 흐름 (단방향)

```
View(UIKit) ──행동──▶ ViewModel ──호출──▶ UseCase ──▶ Repository(프로토콜)
   ▲                     │                                    │
   │  @Observable 관찰    │                                    ▼
   └─────────상태─────────┘                          DataSource(ITunesKit/Persistence)
```

- **비동기**: 모든 I/O는 `async/await`. Combine 미사용.
- **상태**: ViewModel은 `@Observable`(Observation)로 상태 노출. UIKit은 `withObservationTracking`으로 구독, SwiftUI는 기본 관찰.
- **동시성**: ViewModel은 `@MainActor`. Repository/DataSource는 `Sendable`.

## DI 전략

- **경량 컨테이너**를 `CoreKit`에 정의(서비스 로케이터형 `DIContainer` + `DIResolver`). 과한 프레임워크 없이 직접 구현.
- **Composition Root = AppUIKit**. 앱 시작 시 Core 구현체(NetworkClient, ITunesClient, Cache 등)를 컨테이너에 등록하고,
  각 피처 Builder(구현체)를 생성해 상호 계약을 주입한다.
- 피처는 **생성자 주입** 우선. Core 인프라는 `resolver`로 획득, 다른 피처 화면은 그 피처의 **Builder 계약**으로 획득.

```swift
// CoreKit — UI 비의존
public protocol DIResolver { func resolve<T>(_ type: T.Type) -> T }
```

## 피처 간 연동 (계약 주입 — god-router 대신)

피처끼리 몰라야 하므로, **각 피처가 자기 진입 계약을 `*Interface`로 노출**하고,
다른 피처는 그 계약 타입만 주입받는다. 구현체 생성/연결은 App에서만 한다.

```swift
// AppDetailInterface — 다른 피처/App이 보는 유일한 표면
// (UIViewController를 노출하므로 Interface 타깃은 UIKit 의존 허용. CoreKit은 순수 유지.)
public protocol AppDetailBuilder {
    func build(appID: Int) -> UIViewController
}

// SeeAllInterface — 차트 전체 목록 화면. 파라미터 타입도 Interface가 소유.
public enum ChartFeedKind: Sendable { case topFree, topPaid }

public struct SeeAllInput: Sendable {
    public let title: String        // 예: "인기 무료 앱"
    public let feed: ChartFeedKind
    public let genreID: Int?        // nil = 전체, 6014 = 게임 (Games 탭의 "모두 보기")
}

public protocol SeeAllBuilder {
    func build(input: SeeAllInput) -> UIViewController
}
```

```swift
// SearchInterface — Search 피처의 진입 계약
public protocol SearchBuilder { func build() -> UIViewController }

// Search(구현)는 필요한 다른 피처 계약을 생성자로 주입받는다 (구현은 모름)
public struct DefaultSearchBuilder: SearchBuilder {
    private let appDetail: AppDetailBuilder   // AppDetailInterface 의 계약
    public func build() -> UIViewController { /* SearchViewModel에 appDetail 주입 */ }
}
```

- Today/Apps/Search 등은 **필요한 피처의 `*Builder` 계약만** 알고 `appDetail.build(appID:)`을 호출.
- AppUIKit이 `DefaultAppDetailBuilder` 등 **구현체를 생성**하여 각 피처 Builder에 주입.
- 결과적으로 **피처 → 피처 직접 의존이 0**, 이동 로직이 하나의 god-router로 몰리지 않는다(분산·타입 안전).

> **왜 god-router(`AppStoreRouter`)를 버리는가**: (1) 단일 프로토콜이 모든 이동을 떠안아 병목·충돌 지점이 됨,
> (2) `UIViewController`를 노출해 CoreKit의 UI 비의존 규칙을 위반함. 계약 주입 방식은 둘 다 해소하고
> "어느 피처가 무엇을 부르는지"를 타입으로 드러내 대규모에서 유리하다.
> 이동이 폭증하면 App 내부에 얇은 Coordinator를 둘 수 있으나, **여전히 Builder 계약들을 조합**하는 형태를 유지한다.

## UIKit → SwiftUI 교체 지점

- 교체 대상은 **Presentation의 View뿐**. ViewModel/UseCase/Repository/Entity는 그대로 재사용.
- SwiftUI 버전은 `AppSwiftUI` 앱 타깃 + 피처 내 `Presentation/View`에 SwiftUI 뷰를 추가(같은 ViewModel 주입).
- `*Builder` 계약이 `UIViewController`를 반환하므로, SwiftUI 화면은 `UIHostingController`로 감싸 동일 계약을 만족시킨다.
- 따라서 ViewModel은 UIKit/SwiftUI 어느 것도 import 하지 않는다.
