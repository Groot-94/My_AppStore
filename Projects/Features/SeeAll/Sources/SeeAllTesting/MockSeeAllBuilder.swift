//
//  MockSeeAllBuilder.swift
//  SeeAllTesting
//
//  Created by groot on 7/29/26.
//

import UIKit
import SeeAllInterface

/// `SeeAllBuilder` 계약 Mock. 타 피처 Example/테스트에서 주입해 호출을 기록한다.
@MainActor
public final class MockSeeAllBuilder: SeeAllBuilder {
    public private(set) var buildCallCount = 0
    public private(set) var lastInput: SeeAllInput?

    public init() {}

    public func build(input: SeeAllInput) -> UIViewController {
        buildCallCount += 1
        lastInput = input
        return MockLabelViewController(text: "SeeAll Mock\ntitle: \(input.title)\ngenreID: \(input.genreID.map(String.init) ?? "nil")")
    }
}
