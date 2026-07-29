//
//  DefaultAppDetailBuilder.swift
//  AppDetail
//
//  Created by groot on 7/29/26.
//

import UIKit
import AppDetailInterface

/// AppDetail 구현 Builder. 현재는 placeholder 화면을 반환한다.
public struct DefaultAppDetailBuilder: AppDetailBuilder {
    public init() {}

    public func build(appID: Int) -> UIViewController {
        PlaceholderViewController(label: "AppDetail (appID: \(appID))")
    }
}
