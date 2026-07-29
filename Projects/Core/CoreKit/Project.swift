//
//  Project.swift
//  CoreKit
//
//  Created by groot on 7/29/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(
    name: "CoreKit",
    targets: [
        .framework(name: "CoreKit"),
    ]
)
