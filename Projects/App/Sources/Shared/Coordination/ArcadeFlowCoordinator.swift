//
//  ArcadeFlowCoordinator.swift
//  App
//
//  Created by groot on 8/13/26.
//

import UIKit
import AppDetailInterface
import Arcade
import ArcadeInterface

/// 아케이드 플로우. `ArcadeRouting` 상향 이벤트를 앱 상세 push 로 바꾼다.
///
/// 라우트(프로토콜 메서드)를 하나라도 추가하면 이 타입이 컴파일 실패하므로 App 이 처리를 누락할 수 없다.
@MainActor
final class ArcadeFlowCoordinator: Coordinator, AppDetailPresenting, ArcadeRouting {
    var onFinish: (() -> Void)?
    let router: Router
    let appDetailBuilder: AppDetailBuilder

    private let infra: AppInfra

    init(router: Router, infra: AppInfra, appDetailBuilder: AppDetailBuilder) {
        self.router = router
        self.infra = infra
        self.appDetailBuilder = appDetailBuilder
    }

    func start() {
        let root = DefaultArcadeBuilder(
            iTunesClient: infra.iTunesClient,
            imageLoader: infra.imageLoader,
            router: self
        ).build()
        router.setRoot(root)
    }

    // MARK: - ArcadeRouting

    func arcadeDidSelectApp(id: Int) { pushAppDetail(id: id) }
}
