//
//  MockArcadeBuilder.swift
//  ArcadeTesting
//
//  Created by groot on 7/29/26.
//

import UIKit
import ArcadeInterface

/// `ArcadeBuilder` 계약 Mock. 타 피처 Example/테스트에서 주입해 호출을 기록한다.
@MainActor
public final class MockArcadeBuilder: ArcadeBuilder {
    public private(set) var buildCallCount = 0

    public init() {}

    public func build() -> UIViewController {
        buildCallCount += 1
        return MockLabelViewController(text: "Arcade Mock")
    }
}
