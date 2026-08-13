//
//  SearchBuilder.swift
//  SearchInterface
//
//  Created by groot on 7/29/26.
//

import UIKit

/// Search 진입 계약. `build()` 가 UIViewController 를 생성하므로 메인 액터에서 수행한다.
@MainActor
public protocol SearchBuilder {
    func build() -> UIViewController
}

/// Search 상향 이벤트 계약. 피처는 이 delegate 로만 라우팅 의사를 방출하고 App 이 목적지를 소유한다.
@MainActor
public protocol SearchRouting: AnyObject {
    func searchDidSelectApp(id: Int)
}
