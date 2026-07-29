//
//  GamesBuilder.swift
//  GamesInterface
//
//  Created by groot on 7/29/26.
//

import UIKit

/// Games 진입 계약.
/// `build` 가 UIViewController 를 생성하므로 메인 액터에서 수행한다.
@MainActor
public protocol GamesBuilder {
    func build() -> UIViewController
}
