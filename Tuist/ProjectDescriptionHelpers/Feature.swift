import ProjectDescription

// MARK: - Core 모듈 참조 헬퍼
//
// Core 모듈은 각자 독립 프로젝트(Projects/Core/<Module>)를 갖는다 — 피처와 동일한 단위.

public extension TargetDependency {
    static let coreKit: TargetDependency = .project(target: "CoreKit", path: .relativeToRoot("Projects/Core/CoreKit"))
    static let networking: TargetDependency = .project(target: "Networking", path: .relativeToRoot("Projects/Core/Networking"))
    static let persistence: TargetDependency = .project(target: "Persistence", path: .relativeToRoot("Projects/Core/Persistence"))
    static let iTunesKit: TargetDependency = .project(target: "ITunesKit", path: .relativeToRoot("Projects/Core/ITunesKit"))
    static let iTunesKitTesting: TargetDependency = .project(target: "ITunesKitTesting", path: .relativeToRoot("Projects/Core/ITunesKit"))
    static let designSystem: TargetDependency = .project(target: "DesignSystem", path: .relativeToRoot("Projects/Core/DesignSystem"))

    /// 타 피처의 Interface 타깃 참조(피처 → 피처는 Interface만 허용).
    static func featureInterface(_ name: String) -> TargetDependency {
        .project(target: "\(name)Interface", path: .relativeToRoot("Projects/Features/\(name)"))
    }

    /// 타 피처의 Testing 타깃 참조(Example 앱이 타 피처 계약을 Mock 으로 주입).
    static func featureTesting(_ name: String) -> TargetDependency {
        .project(target: "\(name)Testing", path: .relativeToRoot("Projects/Features/\(name)"))
    }
}

// MARK: - Feature 프로젝트 팩토리
//
// 피처당 Interface + Implementation 2타깃(Testing/Example 은 M0 범위 밖).
// 피처 추가 비용을 상수화하기 위해 이 팩토리 하나로 생성한다.

public extension Project {
    /// 피처 프로젝트 생성.
    /// - Parameters:
    ///   - name: 피처 이름(PascalCase). 예: `Search`.
    ///   - interfaceDependencies: `XxxInterface` 가 소유 타입 계약을 위해 필요로 하는 추가 의존(기본 CoreKit + UIKit link).
    ///   - implDependencies: `Xxx`(Impl) 의 추가 의존. 자기 Interface + ITunesKit + DesignSystem 은 자동 주입.
    ///   - implHasResources: Impl 정적 리소스(`Sources/Xxx/Resources/**`) 포함 여부.
    ///   - tests: `true` 면 `XxxTests` 유닛 테스트 타깃 생성(Impl 을 `@testable import`).
    ///   - testDependencies: 테스트 타깃의 추가 의존(피검증 Core 모듈 등). Impl 은 자동 주입.
    ///   - testHasResources: 테스트 픽스처(`Tests/XxxTests/Fixtures/**`) 포함 여부.
    ///   - testing: `true` 면 `XxxTesting`(계약 Mock) 프레임워크 생성 — 자기 Interface 에만 의존.
    ///   - example: `true` 면 `XxxExample` 데모 앱 + 단일 스킴(항상 오프라인 스텁) 생성.
    ///   - exampleDependencies: Example 앱의 추가 의존(타 피처 `*Testing` 등). Impl/DesignSystem/Core 는 자동 주입.
    static func feature(
        name: String,
        interfaceDependencies: [TargetDependency] = [],
        implDependencies: [TargetDependency] = [],
        implHasResources: Bool = false,
        tests: Bool = false,
        testDependencies: [TargetDependency] = [],
        testHasResources: Bool = false,
        testing: Bool = false,
        example: Bool = false,
        exampleDependencies: [TargetDependency] = []
    ) -> Project {
        let interfaceTarget = Target.framework(
            name: "\(name)Interface",
            // Interface 는 CoreKit(+반환 타입용 UIKit) 에만 의존.
            dependencies: [.coreKit] + interfaceDependencies
        )

        let implTarget = Target.framework(
            name: name,
            // 모든 Impl: 자기 Interface + CoreKit + ITunesKit + DesignSystem + 추가 의존.
            dependencies: [
                .target(name: "\(name)Interface"),
                .coreKit,
                .iTunesKit,
                .designSystem,
            ] + implDependencies,
            hasResources: implHasResources
        )

        var targets: [Target] = [interfaceTarget, implTarget]

        if tests {
            let testTarget = Target.unitTest(
                name: "\(name)Tests",
                dependencies: [.target(name: name)] + testDependencies,
                hasResources: testHasResources
            )
            targets.append(testTarget)
        }

        if testing {
            // Testing: 계약 Mock. 자기 Interface 에만 의존(UIKit 은 라벨 VC 반환용으로 link).
            let testingTarget = Target.framework(
                name: "\(name)Testing",
                dependencies: [.target(name: "\(name)Interface")]
            )
            targets.append(testingTarget)
        }

        if example {
            // Example: 자기 Impl(전이로 DesignSystem/CoreKit/ITunesKit 확보) + 로컬 인프라(Persistence)
            //          + 오프라인 네트워크 스텁(ITunesKitTesting) + (타 피처) Testing.
            let exampleTarget = Target.app(
                name: "\(name)Example",
                bundleId: "\(Constants.bundleIDPrefix).example.\(name.lowercased())",
                dependencies: [
                    .target(name: name),
                    .persistence,
                    .iTunesKitTesting,
                ] + exampleDependencies,
                hasResources: false
            )
            targets.append(exampleTarget)
        }

        // 명시적 `schemes` 를 넘기면 Tuist 자동 스킴 생성이 꺼지므로,
        // 피처 기본 스킴(Interface/Impl/Testing/Tests 흡수) + Example 실 API/Mock 스킴을 직접 정의한다.
        var schemes: [Scheme] = []
        if example {
            schemes.append(.featureDefault(name: name, hasTests: tests))
            schemes.append(.exampleApp(name: name))
        }

        return .project(
            name: name,
            targets: targets,
            schemes: schemes
        )
    }
}

// MARK: - Project 편의 생성자

public extension Project {
    static func project(name: String, targets: [Target], schemes: [Scheme] = []) -> Project {
        .init(
            name: name,
            settings: .appStoreBase,
            targets: targets,
            schemes: schemes
        )
    }
}

// MARK: - 피처 스킴

public extension Scheme {
    /// 피처 기본 스킴. Impl 을 빌드하고(있으면) 유닛 테스트를 실행한다.
    /// Interface/Testing 은 의존으로 함께 빌드된다.
    static func featureDefault(name: String, hasTests: Bool) -> Scheme {
        let impl = TargetReference.target(name)
        return .scheme(
            name: name,
            shared: true,
            buildAction: .buildAction(targets: [impl]),
            testAction: hasTests
                ? .targets([.testableTarget(target: .target("\(name)Tests"))])
                : nil
        )
    }

    /// `XxxExample` 스킴. 오프라인 픽스처 스텁으로 피처 단독 확인(런치 인자 없음).
    static func exampleApp(name: String) -> Scheme {
        let target = TargetReference.target("\(name)Example")
        return .scheme(
            name: "\(name)Example",
            shared: true,
            buildAction: .buildAction(targets: [target]),
            runAction: .runAction(configuration: "Debug", executable: target)
        )
    }
}
