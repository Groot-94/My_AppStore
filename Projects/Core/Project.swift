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
    ]
)
