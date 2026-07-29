//
//  Project.swift
//  SeeAll
//
//  Created by groot on 7/29/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

// SeeAll: Impl → AppDetailInterface + Persistence(이미지 로더).
let project = Project.feature(
    name: "SeeAll",
    implDependencies: [
        .featureInterface("AppDetail"),
        .persistence,
    ],
    tests: true,
    testDependencies: [
        .iTunesKit,
        .coreKit,
    ],
    testHasResources: true
)
