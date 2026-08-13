//
//  SearchFlowCoordinator.swift
//  App
//
//  Created by groot on 8/13/26.
//

import UIKit
import AppDetailInterface
import Search
import SearchInterface

/// 검색 플로우. `SearchRouting` 상향 이벤트를 앱 상세 push 로 바꾼다.
///
/// 라우트(프로토콜 메서드)를 하나라도 추가하면 이 타입이 컴파일 실패하므로 App 이 처리를 누락할 수 없다.
@MainActor
final class SearchFlowCoordinator: Coordinator, AppDetailPresenting, SearchRouting {
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
        let root = DefaultSearchBuilder(
            iTunesClient: infra.iTunesClient,
            recentSearchStore: infra.recentSearchStore,
            imageLoader: infra.imageLoader,
            router: self
        ).build()
        router.setRoot(root)
    }

    // MARK: - SearchRouting

    func searchDidSelectApp(id: Int) { pushAppDetail(id: id) }
}
