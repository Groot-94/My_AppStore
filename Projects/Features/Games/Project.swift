//
//  Project.swift
//  Games
//
//  Created by groot on 7/29/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

// Games: Impl → AppDetailInterface + SeeAllInterface + Persistence. 정적 큐레이션 리소스 포함.
let project = Project.feature(
    name: "Games",
    implDependencies: [
        .featureInterface("AppDetail"),
        .featureInterface("SeeAll"),
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
