//
//  AppDetailBuilder.swift
//  AppDetailInterface
//
//  Created by groot on 7/29/26.
//

import UIKit

/// AppDetail 진입 계약. 다른 피처/App 이 보는 유일한 표면.
/// `build` 가 UIViewController 를 생성하므로 메인 액터에서 수행한다.
@MainActor
public protocol AppDetailBuilder {
    func build(appID: Int) -> UIViewController
}
