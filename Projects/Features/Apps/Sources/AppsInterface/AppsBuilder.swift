//
//  AppsBuilder.swift
//  AppsInterface
//
//  Created by groot on 7/29/26.
//

import UIKit

/// Apps 진입 계약.
/// `build` 가 UIViewController 를 생성하므로 메인 액터에서 수행한다.
@MainActor
public protocol AppsBuilder {
    func build() -> UIViewController
}

/// Apps 차트 종류. Interface 가 소유(SeeAll 비의존 유지) — App 이 SeeAll 입력으로 매핑한다.
public enum AppsChartKind: Sendable {
    case topFree
    case topPaid
}

/// Apps 상향 이벤트 계약. 피처는 이 delegate 로만 라우팅 의사를 방출하고 App 이 목적지를 소유한다.
@MainActor
public protocol AppsRouting: AnyObject {
    func appsDidSelectApp(id: Int)
    func appsDidRequestSeeAll(title: String, kind: AppsChartKind, genreID: Int?)
}
