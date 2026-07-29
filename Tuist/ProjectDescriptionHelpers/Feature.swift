import ProjectDescription

// MARK: - Core 모듈 참조 헬퍼
//
// Core 는 별도 프로젝트(Projects/Core)에 있으므로 project 경로 의존으로 참조한다.

public extension TargetDependency {
    static let coreKit: TargetDependency = .project(target: "CoreKit", path: .relativeToRoot("Projects/Core"))
    static let networking: TargetDependency = .project(target: "Networking", path: .relativeToRoot("Projects/Core"))
    static let persistence: TargetDependency = .project(target: "Persistence", path: .relativeToRoot("Projects/Core"))
    static let iTunesKit: TargetDependency = .project(target: "ITunesKit", path: .relativeToRoot("Projects/Core"))
    static let designSystem: TargetDependency = .project(target: "DesignSystem", path: .relativeToRoot("Projects/Core"))

    /// 타 피처의 Interface 타깃 참조(피처 → 피처는 Interface만 허용).
    static func featureInterface(_ name: String) -> TargetDependency {
        .project(target: "\(name)Interface", path: .relativeToRoot("Projects/Features/\(name)"))
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
    static func feature(
        name: String,
        interfaceDependencies: [TargetDependency] = [],
        implDependencies: [TargetDependency] = []
    ) -> Project {
        let interfaceTarget = Target.framework(
            name: "\(name)Interface",
            // Interface 는 CoreKit(+반환 타입용 UIKit) 에만 의존.
            dependencies: [.coreKit] + interfaceDependencies
        )

        let implTarget = Target.framework(
            name: name,
            // 모든 Impl: 자기 Interface + ITunesKit + DesignSystem + 추가 의존.
            dependencies: [
                .target(name: "\(name)Interface"),
                .iTunesKit,
                .designSystem,
            ] + implDependencies
        )

        return .project(
            name: name,
            targets: [interfaceTarget, implTarget]
        )
    }
}

// MARK: - Project 편의 생성자

public extension Project {
    static func project(name: String, targets: [Target]) -> Project {
        .init(
            name: name,
            settings: .appStoreBase,
            targets: targets
        )
    }
}
