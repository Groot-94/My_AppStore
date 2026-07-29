//
//  Project.swift
//  SeeAll
//
//  Created by groot on 7/29/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

// SeeAll: Impl → AppDetailInterface.
let project = Project.feature(
    name: "SeeAll",
    implDependencies: [.featureInterface("AppDetail")]
)
