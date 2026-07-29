//
//  Project.swift
//  DesignSystem
//
//  Created by groot on 7/29/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(
    name: "DesignSystem",
    targets: [
        .framework(
            name: "DesignSystem",
            dependencies: [.coreKit]
        ),
    ]
)
