//
//  Project.swift
//  Persistence
//
//  Created by groot on 7/29/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(
    name: "Persistence",
    targets: [
        .framework(
            name: "Persistence",
            dependencies: [.coreKit]
        ),
        .unitTest(
            name: "PersistenceTests",
            dependencies: [
                .target(name: "Persistence"),
                .coreKit,
            ]
        ),
    ]
)
