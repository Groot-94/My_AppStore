//
//  Project.swift
//  Arcade
//
//  Created by groot on 7/29/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

// Arcade: Impl → AppDetailInterface.
let project = Project.feature(
    name: "Arcade",
    implDependencies: [.featureInterface("AppDetail")]
)
