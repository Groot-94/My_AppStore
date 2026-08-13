//
//  AppCoordinator.swift
//  AppUIKit
//
//  Created by groot on 8/13/26.
//

import UIKit
import AppDetail
import AppDetailInterface

/// 루트 코디네이터. 인프라를 1회 생성하고, **탭별 네비게이션 스택을 소유**하며,
/// 각 플로우 코디네이터에 그 스택을 주입해 `start()` 로 시작시킨 뒤 `UITabBarController` 로 배치한다.
///
/// 탭 순서: [투데이 | 게임 | 앱 | 아케이드 | 검색]
@MainActor
final class AppCoordinator {
    let tabBarController = UITabBarController()

    /// 플로우 코디네이터(=router)를 앱 수명 동안 유지한다 — 피처 VC 는 router 를 약참조하므로.
    private var children: [Coordinator] = []
    private let infra = AppInfra.make()

    func start() {
        children = [
            tab(title: "투데이", symbol: "doc.text.image") {
                TodayFlowCoordinator(navigationController: $0, infra: infra, appDetailBuilder: makeAppDetailBuilder())
            },
            tab(title: "게임", symbol: "gamecontroller") {
                GamesFlowCoordinator(navigationController: $0, infra: infra, appDetailBuilder: makeAppDetailBuilder())
            },
            tab(title: "앱", symbol: "square.stack.3d.up") {
                AppsFlowCoordinator(navigationController: $0, infra: infra, appDetailBuilder: makeAppDetailBuilder())
            },
            tab(title: "아케이드", symbol: "arcade.stick") {
                ArcadeFlowCoordinator(navigationController: $0, infra: infra, appDetailBuilder: makeAppDetailBuilder())
            },
            tab(title: "검색", symbol: "magnifyingglass") {
                SearchFlowCoordinator(navigationController: $0, infra: infra, appDetailBuilder: makeAppDetailBuilder())
            },
        ]
        tabBarController.viewControllers = children.map(\.navigationController)

        // 스크린샷/UITest 지원: `-initialTab <index>` 로 시작 탭 지정(없으면 기본 0).
        // NSArgumentDomain 은 값을 문자열로 저장하므로 integer(forKey:) 로 읽는다.
        let requestedTab = UserDefaults.standard.integer(forKey: "initialTab")
        if requestedTab > 0, requestedTab < children.count {
            tabBarController.selectedIndex = requestedTab
        }
    }

    /// 탭 네비게이션 스택을 생성(루트 소유)해 코디네이터에 주입하고, 탭 아이템을 붙여 `start()` 한다.
    private func tab(title: String, symbol: String, makeCoordinator: (UINavigationController) -> Coordinator) -> Coordinator {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: symbol), selectedImage: nil)
        let coordinator = makeCoordinator(navigationController)
        coordinator.start()
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
