//
//  Project.swift
//  Apps
//
//  Created by groot on 7/29/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

// Apps: Impl → AppDetailInterface + SeeAllInterface.
let project = Project.feature(
    name: "Apps",
    implDependencies: [
        .featureInterface("AppDetail"),
        .featureInterface("SeeAll"),
    ]
)
