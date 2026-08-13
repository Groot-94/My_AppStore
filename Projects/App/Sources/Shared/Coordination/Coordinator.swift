//
//  Coordinator.swift
//  App
//
//  Created by groot on 8/13/26.
//

import UIKit
import AppDetailInterface

/// 플로우 하나의 라우팅 담당. 화면 제시는 주입받은 `Router` 가 맡고, `start()` 에서 루트 화면을 세운다.
///
/// `onFinish` 는 모달/자식 플로우가 끝났음을 부모(AppCoordinator)에 알려 생명주기(detach)를 넘긴다.
@MainActor
protocol Coordinator: AnyObject {
    var onFinish: (() -> Void)? { get set }
    func start()
}

/// App 상세로 push 하는 공통 목적지. 상세는 어느 플로우에서나 같은 방식으로 열린다.
@MainActor
protocol AppDetailPresenting: Coordinator {
    var router: Router { get }
    var appDetailBuilder: AppDetailBuilder { get }
}

extension AppDetailPresenting {
    func pushAppDetail(id: Int) {
        router.push(appDetailBuilder.build(appID: id), animated: true)
    }
}
