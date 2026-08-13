//
//  AppCoordinator.swift
//  AppUIKit
//
//  Created by groot on 8/13/26.
//

import UIKit

/// 루트 코디네이터. 인프라를 1회 생성하고, **탭별 네비게이션 스택을 소유**하며,
/// 각 플로우 코디네이터에 그 스택을 주입해 `start()` 로 시작시킨 뒤 `UITabBarController` 로 배치한다.
///
/// 탭 순서: [투데이 | 게임 | 앱 | 아케이드 | 검색]
@MainActor
final class AppCoordinator {
    let tabBarController = UITabBarController()

    /// 플로우 코디네이터(=router)를 앱 수명 동안 유지한다 — 피처 VC 는 router 를 약참조하므로.
    private var children: [Coordinator] = []
    private let factory = FlowCoordinatorFactory(infra: .make())

    func start() {
        children = [
            tab(title: "투데이", symbol: "doc.text.image", make: factory.makeToday),
            tab(title: "게임", symbol: "gamecontroller", make: factory.makeGames),
            tab(title: "앱", symbol: "square.stack.3d.up", make: factory.makeApps),
            tab(title: "아케이드", symbol: "arcade.stick", make: factory.makeArcade),
            tab(title: "검색", symbol: "magnifyingglass", make: factory.makeSearch),
        ]
        tabBarController.viewControllers = children.map(\.navigationController)

        let requested = LaunchArguments.initialTab
        if requested > 0, requested < children.count {
            tabBarController.selectedIndex = requested
        }
    }

    /// 탭 네비게이션 스택을 생성(루트 소유)해 코디네이터에 주입하고, 탭 아이템을 붙여 `start()` 한다.
    private func tab(title: String, symbol: String, make: (UINavigationController) -> Coordinator) -> Coordinator {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: symbol), selectedImage: nil)
        let coordinator = make(navigationController)
        coordinator.start()
        return coordinator
    }
}
