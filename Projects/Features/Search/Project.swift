//
//  Project.swift
//  Search
//
//  Created by groot on 7/29/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Search",
    implDependencies: [
        .featureInterface("AppDetail"),
        .persistence,
    ],
    tests: true,
    testDependencies: [
        .persistence,
        .iTunesKit,
        .coreKit,
    ],
    testHasResources: true,
    testing: true,
    example: true,
    exampleDependencies: [.featureTesting("AppDetail")]
)
