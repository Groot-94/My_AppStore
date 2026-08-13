//
//  Coordinator.swift
//  App
//
//  Created by groot on 8/13/26.
//

import UIKit
import AppDetailInterface

/// 플로우 하나의 라우팅 소유자. 자기 `UINavigationController` 스택을 소유하고 `start()` 에서 루트를 세운다.
@MainActor
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}

/// App 상세로 push 하는 공통 목적지. 상세는 어느 플로우에서나 같은 방식으로 열린다.
@MainActor
protocol AppDetailPresenting: Coordinator {
    var appDetailBuilder: AppDetailBuilder { get }
}

extension AppDetailPresenting {
    func pushAppDetail(id: Int) {
        navigationController.pushViewController(appDetailBuilder.build(appID: id), animated: true)
    }
}
