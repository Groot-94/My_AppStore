//
//  Project.swift
//  Networking
//
//  Created by groot on 7/29/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(
    name: "Networking",
    targets: [
        .framework(
            name: "Networking",
            dependencies: [.coreKit]
        ),
        .unitTest(
            name: "NetworkingTests",
            dependencies: [
                .target(name: "Networking"),
                .coreKit,
            ]
        ),
    ]
)
