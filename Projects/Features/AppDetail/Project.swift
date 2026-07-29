//
//  Project.swift
//  AppDetail
//
//  Created by groot on 7/29/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

// AppDetail: 타 피처 의존 없음. Impl 은 Persistence 추가(Lookup 응답 캐시).
let project = Project.feature(
    name: "AppDetail",
    implDependencies: [.persistence]
)
