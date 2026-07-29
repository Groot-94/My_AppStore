//
//  DefaultTodayBuilder.swift
//  Today
//
//  Created by groot on 7/29/26.
//

import UIKit
import TodayInterface
import AppDetailInterface

/// Today 구현 Builder. AppDetail 계약을 생성자 주입받는다.
public struct DefaultTodayBuilder: TodayBuilder {
    private let appDetail: AppDetailBuilder

    public init(appDetail: AppDetailBuilder) {
        self.appDetail = appDetail
    }

    public func build() -> UIViewController {
        PlaceholderViewController(label: "Today")
    }
}
