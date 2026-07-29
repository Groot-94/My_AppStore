//
//  Project.swift
//  Arcade
//
//  Created by groot on 7/29/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

// Arcade: Impl → AppDetailInterface. 정적 큐레이션 리소스 포함.
let project = Project.feature(
    name: "Arcade",
    implDependencies: [
        .featureInterface("AppDetail"),
        .persistence,
    ],
    implHasResources: true,
    tests: true,
    testDependencies: [
        .iTunesKit,
        .coreKit,
    ],
    testHasResources: true
)
