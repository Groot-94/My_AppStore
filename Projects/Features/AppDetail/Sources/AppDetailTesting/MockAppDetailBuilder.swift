//
//  MockAppDetailBuilder.swift
//  AppDetailTesting
//
//  Created by groot on 7/29/26.
//

import UIKit
import AppDetailInterface

/// `AppDetailBuilder` 계약 Mock. 타 피처 Example/테스트에서 주입해 호출을 기록한다.
@MainActor
public final class MockAppDetailBuilder: AppDetailBuilder {
    public private(set) var buildCallCount = 0
    public private(set) var lastAppID: Int?

    public init() {}

    public func build(appID: Int) -> UIViewController {
        buildCallCount += 1
        lastAppID = appID
        return MockLabelViewController(text: "AppDetail Mock\nappID: \(appID)")
    }
}
