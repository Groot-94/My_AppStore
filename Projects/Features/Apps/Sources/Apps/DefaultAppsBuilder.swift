//
//  DefaultAppsBuilder.swift
//  Apps
//
//  Created by groot on 7/29/26.
//

import UIKit
import AppsInterface
import AppDetailInterface
import SeeAllInterface

/// Apps 구현 Builder. AppDetail + SeeAll 계약을 생성자 주입받는다.
public struct DefaultAppsBuilder: AppsBuilder {
    private let appDetail: AppDetailBuilder
    private let seeAll: SeeAllBuilder

    public init(appDetail: AppDetailBuilder, seeAll: SeeAllBuilder) {
        self.appDetail = appDetail
        self.seeAll = seeAll
    }

    public func build() -> UIViewController {
        PlaceholderViewController(label: "Apps")
    }
}
