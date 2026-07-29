//
//  Project.swift
//  Today
//
//  Created by groot on 7/29/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

// Today: Impl → AppDetailInterface.
let project = Project.feature(
    name: "Today",
    implDependencies: [.featureInterface("AppDetail")]
)
