//
//  Project.swift
//  Games
//
//  Created by groot on 7/29/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

// Games: Impl → AppDetailInterface + SeeAllInterface.
let project = Project.feature(
    name: "Games",
    implDependencies: [
        .featureInterface("AppDetail"),
        .featureInterface("SeeAll"),
    ]
)
