//
//  Project.swift
//  Today
//
//  Created by groot on 7/29/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

// Today: Impl → AppDetailInterface. 정적 큐레이션 리소스 포함.
let project = Project.feature(
    name: "Today",
    implDependencies: [.featureInterface("AppDetail")],
    implHasResources: true,
    tests: true,
    testDependencies: [
        .iTunesKit,
        .coreKit,
    ],
    testHasResources: true
)
