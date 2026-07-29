//
//  Project.swift
//  App
//
//  Created by groot on 7/29/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

/// AppUIKit — Composition Root.
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
            sources: ["Sources/**"],
            dependencies: [
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
            ],
            settings: .appStoreBase
        ),
    ]
)
