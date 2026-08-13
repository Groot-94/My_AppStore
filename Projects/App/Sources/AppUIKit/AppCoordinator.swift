//
//  AppCoordinator.swift
//  AppUIKit
//
//  Created by groot on 8/13/26.
//

import UIKit
import AppDetail
import AppDetailInterface

/// 루트 코디네이터. 인프라를 1회 생성하고, 탭별 플로우 코디네이터를 조립해 `UITabBarController` 로 배치한다.
///
/// 각 플로우 코디네이터는 자기 `UINavigationController` 와 라우팅을 소유하므로 이 타입은 탭 구성만 안다.
/// 탭 순서: [투데이 | 게임 | 앱 | 아케이드 | 검색]
@MainActor
final class AppCoordinator {
    let tabBarController = UITabBarController()

    /// 플로우 코디네이터(=router)를 앱 수명 동안 유지한다 — 피처 VC 는 router 를 약참조하므로.
    private var children: [Coordinator] = []
    private let infra = AppInfra.make()

    func start() {
        children = [
            tab(TodayFlowCoordinator(infra: infra, appDetailBuilder: makeAppDetailBuilder()),
                title: "투데이", symbol: "doc.text.image"),
            tab(GamesFlowCoordinator(infra: infra, appDetailBuilder: makeAppDetailBuilder()),
                title: "게임", symbol: "gamecontroller"),
            tab(AppsFlowCoordinator(infra: infra, appDetailBuilder: makeAppDetailBuilder()),
                title: "앱", symbol: "square.stack.3d.up"),
            tab(ArcadeFlowCoordinator(infra: infra, appDetailBuilder: makeAppDetailBuilder()),
                title: "아케이드", symbol: "arcade.stick"),
            tab(SearchFlowCoordinator(infra: infra, appDetailBuilder: makeAppDetailBuilder()),
                title: "검색", symbol: "magnifyingglass"),
        ]
        tabBarController.viewControllers = children.map(\.navigationController)

        // 스크린샷/UITest 지원: `-initialTab <index>` 로 시작 탭 지정(없으면 기본 0).
        // NSArgumentDomain 은 값을 문자열로 저장하므로 integer(forKey:) 로 읽는다.
        let requestedTab = UserDefaults.standard.integer(forKey: "initialTab")
        if requestedTab > 0, requestedTab < children.count {
            tabBarController.selectedIndex = requestedTab
        }
    }

    /// 플로우를 시작하고 탭 아이템을 붙여 반환한다.
    private func tab(_ coordinator: Coordinator, title: String, symbol: String) -> Coordinator {
        coordinator.start()
        coordinator.navigationController.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: symbol),
            selectedImage: nil
        )
        return coordinator
    }

    private func makeAppDetailBuilder() -> AppDetailBuilder {
        DefaultAppDetailBuilder(
            iTunesClient: infra.iTunesClient,
            cache: infra.cache,
            imageLoader: infra.imageLoader
        )
    }
}
