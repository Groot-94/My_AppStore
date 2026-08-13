//
//  AppComposition.swift
//  AppUIKit
//
//  Created by groot on 8/13/26.
//

import UIKit
import CoreKit
import Networking
import Persistence
import ITunesKit
import AppDetail
import AppDetailInterface
import SeeAll
import SeeAllInterface
import Search
import Today
import Apps
import Games
import Arcade

/// Composition Root. DI 구성 + 탭별 Coordinator 조립 + 탭 구성.
///
/// 각 탭은 자기 `TabCoordinator` 를 갖고, 피처에는 그 코디네이터를 `router:` 로 주입한다.
/// 라우팅(목적지 조립·push)은 전부 코디네이터가 소유하므로 피처는 타 피처를 알지 못한다.
@MainActor
final class AppComposition {

    /// Core 인프라. 앱 수명 동안 1회 생성한다.
    private struct Infra {
        let iTunesClient: ITunesClient
        let cache: Cache
        let imageLoader: ImageLoading
        let recentSearchStore: RecentSearchStore
    }

    /// 탭별 Coordinator 를 앱 수명 동안 유지한다 — 피처 VC 는 router 를 약참조하므로.
    private var coordinators: [TabCoordinator] = []

    // MARK: - Infra

    private func makeInfra() -> Infra {
        let config = StoreConfig.korea
        let networkClient: NetworkClient = URLSessionNetworkClient()
        let iTunesClient: ITunesClient = DefaultITunesClient(network: networkClient, config: config)
        let cache: Cache = DefaultCache()
        return Infra(
            iTunesClient: iTunesClient,
            cache: cache,
            imageLoader: DefaultImageLoader(cache: cache),
            recentSearchStore: DefaultRecentSearchStore()
        )
    }

    /// 탭 하나의 Coordinator 생성. AppDetail 빌더 소유 + SeeAll 조립 팩토리(그 시점 router 주입) 보유.
    private func makeCoordinator(infra: Infra) -> TabCoordinator {
        let appDetailBuilder: AppDetailBuilder = DefaultAppDetailBuilder(
            iTunesClient: infra.iTunesClient,
            cache: infra.cache,
            imageLoader: infra.imageLoader
        )
        return TabCoordinator(
            appDetailBuilder: appDetailBuilder,
            makeSeeAll: { input, router in
                DefaultSeeAllBuilder(
                    iTunesClient: infra.iTunesClient,
                    imageLoader: infra.imageLoader,
                    router: router
                ).build(input: input)
            }
        )
    }

    // MARK: - 탭 조립

    /// 피처 루트를 만들고, 그 탭 Coordinator 에 네비게이션을 연결한 UINavigationController 반환.
    /// `makeRoot` 는 이 탭 Coordinator 를 받아 피처 Builder 에 `router:` 로 주입한다.
    private func makeTab(
        title: String,
        symbol: String,
        infra: Infra,
        makeRoot: (TabCoordinator) -> UIViewController
    ) -> UINavigationController {
        let coordinator = makeCoordinator(infra: infra)
        coordinators.append(coordinator)

        let nav = UINavigationController(rootViewController: makeRoot(coordinator))
        nav.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: symbol), selectedImage: nil)
        coordinator.navigationController = nav
        return nav
    }

    /// 탭 순서: [Today | Games | Apps | Arcade | Search]
    private func makeTabControllers(infra: Infra) -> [UINavigationController] {
        [
            makeTab(title: "투데이", symbol: "doc.text.image", infra: infra) { coordinator in
                DefaultTodayBuilder(
                    iTunesClient: infra.iTunesClient,
                    imageLoader: infra.imageLoader,
                    router: coordinator
                ).build()
            },
            makeTab(title: "게임", symbol: "gamecontroller", infra: infra) { coordinator in
                DefaultGamesBuilder(
                    iTunesClient: infra.iTunesClient,
                    imageLoader: infra.imageLoader,
                    router: coordinator
                ).build()
            },
            makeTab(title: "앱", symbol: "square.stack.3d.up", infra: infra) { coordinator in
                DefaultAppsBuilder(
                    iTunesClient: infra.iTunesClient,
                    imageLoader: infra.imageLoader,
                    router: coordinator
                ).build()
            },
            makeTab(title: "아케이드", symbol: "arcade.stick", infra: infra) { coordinator in
                DefaultArcadeBuilder(
                    iTunesClient: infra.iTunesClient,
                    imageLoader: infra.imageLoader,
                    router: coordinator
                ).build()
            },
            makeTab(title: "검색", symbol: "magnifyingglass", infra: infra) { coordinator in
                DefaultSearchBuilder(
                    iTunesClient: infra.iTunesClient,
                    recentSearchStore: infra.recentSearchStore,
                    imageLoader: infra.imageLoader,
                    router: coordinator
                ).build()
            },
        ]
    }

    func makeRootTabBarController() -> UITabBarController {
        let infra = makeInfra()
        let controllers = makeTabControllers(infra: infra)

        let tabBar = UITabBarController()
        tabBar.viewControllers = controllers

        // 스크린샷/UITest 지원: `-initialTab <index>` 로 시작 탭 지정(없으면 기본 0).
        // NSArgumentDomain 은 값을 문자열로 저장하므로 integer(forKey:) 로 읽는다.
        let requestedTab = UserDefaults.standard.integer(forKey: "initialTab")
        if requestedTab > 0, requestedTab < controllers.count {
            tabBar.selectedIndex = requestedTab
        }
        return tabBar
    }
}
