# 07. 컨벤션

## 언어/동시성
- Swift 6.2, strict concurrency. 공유 타입은 `Sendable`.
- 모든 I/O는 `async/await`. Combine 미사용.
- ViewModel은 `@MainActor` + `@Observable`. UI 상태 변경은 메인 액터에서만.

## 네이밍
- 모듈: PascalCase(`CoreKit`, `AppDetail`).
- 프로토콜: 역할 명사(`NetworkClient`, `SearchRepository`) 또는 능력 `-ing`/`-able`(`ImageLoading`). 진입 계약은 `-Builder`(`AppDetailBuilder`).
- 구현체: `Default` 접두(`DefaultSearchRepository`) 또는 기술 접두(`URLSessionNetworkClient`).
- UseCase: `동사+명사+UseCase`(`SearchAppsUseCase`).
- 파일: 주요 타입명과 일치. 1파일 1주요 타입 원칙.

## 모듈/의존
- 피처는 다른 피처의 **구현** import 금지. 필요 시 그 피처의 `*Interface`(Builder 계약)만 의존하고 구현체는 App이 주입.
- `*Interface`는 CoreKit(+반환 타입용 UIKit)에만 의존. 계약용 공개 타입(`SeeAllInput` 등)은 Interface가 소유. ITunesKit/Networking/Persistence/타 피처 구현 의존 금지.
- **엔티티·UseCase·Repository 프로토콜은 피처가 소유**(공용 Domain 모듈 없음). Domain 폴더 코드는 `import UIKit`/`import ITunesKit`/`import Networking` 금지.
- DesignSystem 컴포넌트는 피처 엔티티를 모른다 — 원시 값/자체 구성 모델(`AppRowCell.Model`)로 입력받는다.
- 공개 API는 명시적 `public`. 내부 구현은 `internal`/`private` 최소 노출.
- 의존 변경 시 `tuist generate` 재실행 + `tuist graph` 확인.

## 접근 제어로 계층 경계 강제
- 같은 모듈 내 계층은 접근 제어 + 컨벤션으로 구분(별도 타깃 아님).
- Repository 구현은 피처 Builder에서만 생성(주입). Presentation은 UseCase만 호출.
- **기계 검증**: SwiftLint 커스텀 룰로 `Domain/` 폴더 내 `import UIKit`/`import ITunesKit`/`import Networking`을 차단(CI에서 실행). 컨벤션 규칙 중 유일하게 선언만으로 끝나지 않도록 함.

## 에러/상태
- 화면 상태는 `enum State`로 명시(`loading/loaded/empty/failed`).
- 사용자 노출 메시지는 피처에서 생성. Core는 도메인/네트워크 에러만 던짐.

## 테스트
- 프레임워크: XCTest(또는 Swift Testing 검토).
- 대상 우선순위: UseCase > Mapper > ViewModel.
- 네트워크는 `NetworkClient` 목으로 대체. 고정 JSON 픽스처 사용.

## 포매팅
- SwiftFormat/SwiftLint 도입(설정은 M1에서 확정). 들여쓰기 4스페이스.

## 리소스
- 정적 큐레이션 JSON은 해당 피처 `Resources/`에 위치.
- 색/폰트/이미지 애셋은 `DesignSystem`에 집중.

## 커밋
- 논리 단위로 커밋. 생성물(`.xcodeproj`/`.xcworkspace`)은 커밋하지 않음(→ `.gitignore`).
