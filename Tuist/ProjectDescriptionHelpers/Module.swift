import ProjectDescription

// MARK: - 전역 상수

public enum Constants {
    public static let bundleIDPrefix = "com.groot94.myappstore"
    public static let deploymentTarget: DeploymentTargets = .iOS("17.0")
    public static let destinations: Destinations = .iOS
    public static let swiftVersion = "6.2"
}

// MARK: - 공통 설정 (Swift 6.2 + strict concurrency=complete)

public extension Settings {
    /// 전 타깃 공통 baseline 설정.
    static var appStoreBase: Settings {
        .settings(
            base: [
                "SWIFT_VERSION": SettingValue(stringLiteral: Constants.swiftVersion),
                "SWIFT_STRICT_CONCURRENCY": "complete",
                "IPHONEOS_DEPLOYMENT_TARGET": "17.0",
            ],
            configurations: [
                .debug(name: "Debug"),
                .release(name: "Release"),
            ]
        )
    }
}

// MARK: - Target 팩토리

public extension Target {
    /// UI 비의존 / 의존 프레임워크 타깃(리소스 없음 — 빌드 캐시 적중률↑).
    ///
    /// 소스는 타깃별 폴더(`Sources/<name>/**`)만 글롭한다 — 한 프로젝트에 여러 타깃이
    /// 있어도 서로의 소스를 삼키지 않도록.
    static func framework(
        name: String,
        dependencies: [TargetDependency] = [],
        hasResources: Bool = false
    ) -> Target {
        .target(
            name: name,
            destinations: Constants.destinations,
            product: .framework,
            bundleId: "\(Constants.bundleIDPrefix).\(name.lowercased())",
            deploymentTargets: Constants.deploymentTarget,
            sources: ["Sources/\(name)/**"],
            resources: hasResources ? ["Sources/\(name)/Resources/**"] : [],
            dependencies: dependencies,
            settings: .appStoreBase
        )
    }

    /// 유닛 테스트 번들 타깃.
    ///
    /// - 소스는 `Tests/<name>/**`, 리소스는 `Tests/<name>/Fixtures/**`(선택).
    /// - `dependencies` 로 피검증 프레임워크 타깃을 넣는다.
    static func unitTest(
        name: String,
        dependencies: [TargetDependency] = [],
        hasResources: Bool = false
    ) -> Target {
        .target(
            name: name,
            destinations: Constants.destinations,
            product: .unitTests,
            bundleId: "\(Constants.bundleIDPrefix).\(name.lowercased())",
            deploymentTargets: Constants.deploymentTarget,
            sources: ["Tests/\(name)/**"],
            resources: hasResources ? ["Tests/\(name)/Fixtures/**"] : [],
            dependencies: dependencies,
            settings: .appStoreBase
        )
    }

    /// 앱 타깃(피처 단독 실행 데모).
    ///
    /// - 소스는 `Sources/<name>/**`, 번들 리소스는 `Sources/<name>/Resources/**`.
    /// - SceneDelegate 진입점을 InfoPlist 로 지정한다(스토리보드 미사용).
    static func app(
        name: String,
        bundleId: String,
        dependencies: [TargetDependency] = [],
        hasResources: Bool = false
    ) -> Target {
        .target(
            name: name,
            destinations: Constants.destinations,
            product: .app,
            bundleId: bundleId,
            deploymentTargets: Constants.deploymentTarget,
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": ["UIColorName": ""],
                "UIApplicationSceneManifest": [
                    "UIApplicationSupportsMultipleScenes": false,
                    "UISceneConfigurations": [
                        "UIWindowSceneSessionRoleApplication": [
                            [
                                "UISceneConfigurationName": "Default Configuration",
                                "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate",
                            ]
                        ]
                    ],
                ],
            ]),
            sources: ["Sources/\(name)/**"],
            resources: hasResources ? ["Sources/\(name)/Resources/**"] : [],
            dependencies: dependencies,
            settings: .appStoreBase
        )
    }
}
