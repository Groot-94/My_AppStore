//
//  Project.swift
//  App
//
//  Created by groot on 7/29/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

/// AppUIKit / AppSwiftUI 공통 의존: Core 전부 + 피처 7 Impl.
private let appFeatureDependencies: [TargetDependency] = [
    // Core
    .coreKit,
    .networking,
    .iTunesKit,
    .persistence,
    .designSystem,
    // 모든 피처 Impl
    .project(target: "Today", path: .relativeToRoot("Projects/Features/Today")),
    .project(target: "Games", path: .relativeToRoot("Projects/Features/Games")),
    .project(target: "Apps", path: .relativeToRoot("Projects/Features/Apps")),
    .project(target: "Arcade", path: .relativeToRoot("Projects/Features/Arcade")),
    .project(target: "Search", path: .relativeToRoot("Projects/Features/Search")),
    .project(target: "AppDetail", path: .relativeToRoot("Projects/Features/AppDetail")),
    .project(target: "SeeAll", path: .relativeToRoot("Projects/Features/SeeAll")),
]

/// AppUIKit(기존 5탭) + AppSwiftUI(검색 네이티브 + 나머지 UIKit 인터롭) Composition Root.
let project = Project(
    name: "App",
    settings: .appStoreBase,
    targets: [
        .target(
            name: "AppUIKit",
            destinations: Constants.destinations,
            product: .app,
            bundleId: "\(Constants.bundleIDPrefix).app",
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
            sources: ["Sources/AppUIKit/**", "Sources/Shared/**"],
            dependencies: appFeatureDependencies,
            settings: .appStoreBase
        ),
        .target(
            name: "AppSwiftUI",
            destinations: Constants.destinations,
            product: .app,
            bundleId: "\(Constants.bundleIDPrefix).swiftui",
            deploymentTargets: Constants.deploymentTarget,
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": ["UIColorName": ""],
            ]),
            sources: ["Sources/AppSwiftUI/**", "Sources/Shared/**"],
            dependencies: appFeatureDependencies,
            settings: .appStoreBase
        ),
    ]
)
