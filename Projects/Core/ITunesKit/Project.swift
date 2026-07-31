//
//  Project.swift
//  ITunesKit
//
//  Created by groot on 7/29/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(
    name: "ITunesKit",
    targets: [
        .framework(
            name: "ITunesKit",
            dependencies: [
                .coreKit,
                .networking,
            ]
        ),
        .framework(
            name: "ITunesKitTesting",
            dependencies: [.target(name: "ITunesKit")],
            hasResources: true
        ),
        .unitTest(
            name: "ITunesKitTests",
            dependencies: [
                .target(name: "ITunesKit"),
                .networking,
                .coreKit,
            ],
            hasResources: true
        ),
    ]
)
