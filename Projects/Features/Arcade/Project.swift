//
//  Project.swift
//  Arcade
//
//  Created by groot on 7/29/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

// Arcade: 타 피처 의존 0. 상향 라우팅은 ArcadeRouting delegate 로만 방출. 정적 큐레이션 리소스 포함.
let project = Project.feature(
    name: "Arcade",
    implHasResources: true,
    tests: true,
    testDependencies: [
        .iTunesKit,
        .coreKit,
    ],
    testHasResources: true,
    testing: true,
    example: true
)
