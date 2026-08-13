//
//  Project.swift
//  SeeAll
//
//  Created by groot on 7/29/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

// SeeAll: 타 피처 의존 0. 상향 라우팅은 SeeAllRouting delegate 로만 방출.
let project = Project.feature(
    name: "SeeAll",
    tests: true,
    testDependencies: [
        .iTunesKit,
        .coreKit,
    ],
    testHasResources: true,
    testing: true,
    example: true
)
