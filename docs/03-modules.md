# 03. 모듈

Tuist 워크스페이스의 타깃 구성. **Core 5 + Feature(피처당 2~4타깃) + App 1~2**.
피처는 **Interface / Implementation / Testing / Example** 타깃으로 나뉜다(→ [02-architecture](02-architecture.md)).

## 의존 매트릭스 — Core

| 모듈 | 타입 | 의존 | UIKit 의존 |
|------|------|------|:---:|
| CoreKit | framework | — | ✕ |
| Networking | framework | CoreKit | ✕ |
| Persistence | framework | CoreKit | ✕ |
| ITunesKit | framework | CoreKit, Networking | ✕ |
| DesignSystem | framework | CoreKit, Persistence | ○ |

> **공용 Domain/Data 모듈은 없다(확정).** 엔티티·UseCase·Repository는 각 피처가 소유하고(→ [02-architecture](02-architecture.md)),
> 전 피처가 동일하게 반복하는 iTunes 응답 **디코딩(DTO)과 API 호출만 `ITunesKit`으로 공용화**한다.
> (모듈명을 `Data`로 하지 않는 것은 `Foundation.Data` 타입과의 충돌을 피하기 위함이기도 하다.)

## 의존 매트릭스 — Feature (피처당 4타깃)

`Xxx` 예시로 표기(Search/Today/Apps/Games/Arcade/AppDetail/SeeAll 동일 패턴).

| 타깃 | 타입 | 의존 | UIKit |
|------|------|------|:---:|
| `XxxInterface` | framework | CoreKit(+ 반환 타입 위해 UIKit) | ○(최소) |
| `Xxx` (Impl) | framework | `XxxInterface`, ITunesKit, DesignSystem, (필요 시) Persistence, **의존하는 타 피처의 `*Interface`** | ○ |
| `XxxTesting` | framework | `XxxInterface` | ✕ |
| `XxxExample` | app | `Xxx`, `XxxTesting`, DesignSystem | ○ |

- **모든 피처 Impl은 Persistence에 의존한다** — 이미지 로딩(`ImageLoading` 프로토콜, Persistence 소유)을 Builder가 주입받기 때문. 추가로 **Search**는 `RecentSearchStore`, **AppDetail**은 Lookup 응답 캐시를 사용.
- 피처는 Networking을 직접 의존하지 않는다 — HTTP 호출은 전부 `ITunesKit.ITunesClient`를 경유.

**피처 간 의존(구현 → 타 피처 Interface)만 허용**:

| 피처(Impl) | 의존하는 타 피처 Interface |
|------|------|
| Search | AppDetailInterface |
| Today | AppDetailInterface |
| Apps | AppDetailInterface, SeeAllInterface |
| Games | AppDetailInterface, SeeAllInterface |
| Arcade | AppDetailInterface |
| AppDetail | — |
| SeeAll | AppDetailInterface |

> 피처 Impl 은 서로를 **절대 import하지 않는다.** 위 표의 화살표는 전부 `*Interface`(계약)를 향한다.

## 의존 매트릭스 — App

| 모듈 | 타입 | 의존 | UIKit |
|------|------|------|:---:|
| AppUIKit | app | 모든 피처 **Impl** + Core | ○ |
| AppSwiftUI | app | 모든 피처 Impl(또는 SwiftUI Builder) + Core | ○(SwiftUI) |

App(Composition Root)은 유일하게 모든 구현을 안다 — 구현체 생성·계약 주입·DI 등록을 담당.

## Core 모듈

### CoreKit
- **책임**: UI/네트워크 비의존 최소 공통 코드.
- **포함**: DI 컨테이너(`DIResolver`/`DIContainer`), 공통 에러 타입, `StoreConfig(country:lang:)`, Foundation 확장, 로거.
- **주의**: `AppStoreRouter` 같은 UIKit 노출 프로토콜을 두지 않는다(UI 비의존 유지).

### Networking
- **책임**: HTTP 통신 추상화 (iTunes를 모르는 범용 계층).
- **공개 API**: `NetworkClient`(프로토콜) + `URLSessionNetworkClient`(구현), 요청 빌더, 디코딩, 네트워크 에러 매핑. 재시도/타임아웃/로깅 포함.

### Persistence
- **책임**: 로컬 저장/캐시 추상화.
- **공개 API**: `Cache`(이미지/응답 메모리+디스크), `RecentSearchStore`(UserDefaults), `ImageLoading`.

### ITunesKit
- **책임**: iTunes API 3종(Search/Lookup/RSS)의 **공용 DTO + 호출 클라이언트**. 엔티티·매핑은 소유하지 않는다.
- **공개 API**: `ITunesClient`(프로토콜) + `DefaultITunesClient`(Networking 사용),
  `ITunesAppDTO` / `ITunesSearchResponse` / `RSSEntryDTO`, `ChartFeed`(top-free/top-paid), iTunes 엔드포인트 정의.
- 각 피처의 Data 폴더가 이 DTO를 **자기 엔티티로 매핑**한다(→ [04-data-api](04-data-api.md)).

### DesignSystem
- **책임**: 공통 UIKit 컴포넌트/스타일 + **재사용 화면 컴포넌트**.
- **공개 API**: 색상(`AppColors`), 타이포(`AppFont`), 원자 뷰(`AppIconView`, `RatingView`, `GetButton`, `AppRowCell`, `ScreenshotPager`),
  그리고 **스토어 피드 컴포넌트**(`CarouselView`, `ChartRankRow`, `SectionHeaderView`, `CategoryGridView`) — Apps/Games가 레이아웃을 재사용.
- **엔티티 비의존(확정)**: 컴포넌트 입력은 원시 값/자체 구성 모델(`AppRowCell.Model(iconURL:title:subtitle:)` 등).
  피처가 "자기 엔티티 → 구성 모델" 변환을 담당한다.
- 이미지 로딩은 `Persistence.ImageLoading`을 주입받아 사용.

## Feature 모듈 (공통 형태)

각 피처는 `*Interface`에 **진입 Builder 계약**을 노출한다. 계약에 필요한 공개 타입은 Interface가 소유한다.

```swift
// SearchInterface
public protocol SearchBuilder { func build() -> UIViewController }

// AppDetailInterface
public protocol AppDetailBuilder { func build(appID: Int) -> UIViewController }

// SeeAllInterface — 파라미터 타입(SeeAllInput)도 Interface 소유
public enum ChartFeedKind: Sendable { case topFree, topPaid }
public struct SeeAllInput: Sendable {
    public let title: String        // 예: "인기 무료 앱"
    public let feed: ChartFeedKind
    public let genreID: Int?        // nil = 전체, 6014 = 게임
}
public protocol SeeAllBuilder { func build(input: SeeAllInput) -> UIViewController }
```

- 구현체(`DefaultSearchBuilder` 등)는 Impl 타깃에 있고, 필요한 Core(resolver)·타 피처 계약(Builder)을 생성자로 주입받는다.
- 각 피처 상세 스펙(UI 스케치·흐름 포함)은 [05-features/](05-features/) 참고.

### SeeAll 피처 ("모두 보기" 화면 소유)
- Apps/Games의 "모두 보기"가 이동할 **차트 전체 목록 화면**을 소유하는 독립 피처.
- 입력: `SeeAllInput(title:feed:genreID:)`. `ITunesClient.chart`로 전체 차트를 조회하고, `genreID`가 있으면 장르 필터를 적용해 목록 표시.
- 항목 탭 → `AppDetailBuilder.build(appID:)`. → 피처 간 이동 규칙을 그대로 따른다.

### Apps/Games 공통화 방침
- **레이아웃/셀은 DesignSystem의 스토어 피드 컴포넌트로 재사용**(코드 중복 제거).
- Apps/Games는 각자 Impl에서 그 컴포넌트를 조립하고 **데이터 소스(파라미터)만 다르게 주입**한다.
  (공통 화면을 별도 피처로 빼지 않는다 — 피처 간 import 금지 원칙 유지.)

## App 모듈

### AppUIKit (Composition Root, 우선)
- `UITabBarController`로 5개 탭(Today/Games/Apps/Arcade/Search) 조립.
- DI 컨테이너 구성: `NetworkClient`, `ITunesClient`, `Cache`, `ImageLoading`, `StoreConfig` 등 Core 구현 등록.
- **Builder 조립**: `DefaultAppDetailBuilder`, `DefaultSeeAllBuilder` 등 구현체를 생성해 각 피처 Builder에 주입.
- 앱 진입점(`AppDelegate`/`SceneDelegate`), 프로그래매틱 UI(스토리보드 미사용).

### AppSwiftUI (나중)
- 동일 DI/계약을 SwiftUI(`App`/`Scene`, `TabView`)로 재조립. ViewModel 재사용. SwiftUI 뷰는 `UIHostingController`로 감싸 동일 Builder 계약을 만족.

## Tuist 실무
- `Tuist/ProjectDescriptionHelpers`에 **모듈 팩토리**(`Module.feature(name:)`)를 두어 피처 4타깃을 한 번에 생성 → 피처 추가 비용을 상수화.
- `Interface` 타깃은 리소스 없이 최소화해 빌드 캐시 적중률을 높인다.
- CI에서 `tuist graph`로 순환·역참조 검증.
