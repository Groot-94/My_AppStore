//
//  Project.swift
//  Core
//
//  Created by groot on 7/29/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(
    name: "Core",
    targets: [
        .framework(name: "CoreKit"),
        .framework(
            name: "Networking",
            dependencies: [.target(name: "CoreKit")]
        ),
        .framework(
            name: "Persistence",
            dependencies: [.target(name: "CoreKit")]
        ),
        .framework(
            name: "ITunesKit",
            dependencies: [
                .target(name: "CoreKit"),
                .target(name: "Networking"),
            ]
        ),
        .framework(
            name: "DesignSystem",
            dependencies: [
                .target(name: "CoreKit"),
                .target(name: "Persistence"),
            ]
        ),
        // MARK: 테스트 타깃
        .unitTest(
            name: "NetworkingTests",
            dependencies: [
                .target(name: "Networking"),
                .target(name: "CoreKit"),
            ]
        ),
        .unitTest(
            name: "ITunesKitTests",
            dependencies: [
                .target(name: "ITunesKit"),
                .target(name: "Networking"),
                .target(name: "CoreKit"),
            ],
            hasResources: true
        ),
        .unitTest(
            name: "PersistenceTests",
            dependencies: [
                .target(name: "Persistence"),
                .target(name: "CoreKit"),
            ]
        ),
    ]
)
