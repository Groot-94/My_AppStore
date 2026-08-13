//
//  Coordinator.swift
//  App
//
//  Created by groot on 8/13/26.
//

import UIKit
import AppDetailInterface

/// 플로우 하나의 라우팅 담당. 네비게이션 스택은 루트(AppCoordinator)가 소유해 주입하고,
/// `start()` 에서 루트 화면을 세우며 이후 이동(push/present)을 관리한다.
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
