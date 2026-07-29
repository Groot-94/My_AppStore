import ProjectDescription
import ProjectDescriptionHelpers

// Core 5 프레임워크. 의존 매트릭스(docs/03-modules.md):
//   Networking  → CoreKit
//   Persistence → CoreKit
//   ITunesKit   → CoreKit, Networking
//   DesignSystem→ CoreKit, Persistence  (UIKit 의존)
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
        // MARK: 테스트 타깃 (M1)
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
