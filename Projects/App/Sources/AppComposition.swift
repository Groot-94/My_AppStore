//
//  AppComposition.swift
//  AppUIKit
//
//  Created by groot on 7/29/26.
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

/// Composition Root. DI 구성 + 피처 Builder 조립 + 탭 구성.
struct AppComposition {

    /// DI 컨테이너 구성. Core 구현체 등록.
    private func makeContainer() -> DIContainer {
        let container = DIContainer()

        let config = StoreConfig.korea
        container.register(StoreConfig.self) { config }

        let networkClient: NetworkClient = URLSessionNetworkClient()
        container.register(NetworkClient.self) { networkClient }

        let iTunesClient: ITunesClient = DefaultITunesClient(network: networkClient, config: config)
        container.register(ITunesClient.self) { iTunesClient }

        let cache: Cache = DefaultCache()
        container.register(Cache.self) { cache }

        let imageLoader: ImageLoading = DefaultImageLoader(cache: cache)
        container.register(ImageLoading.self) { imageLoader }

        let recentSearchStore: RecentSearchStore = DefaultRecentSearchStore()
        container.register(RecentSearchStore.self) { recentSearchStore }

        return container
    }

    @MainActor
    func makeRootTabBarController() -> UITabBarController {
        let container = makeContainer()

        let iTunesClient = container.resolve(ITunesClient.self)
        let cache = container.resolve(Cache.self)
        let imageLoader = container.resolve(ImageLoading.self)
        let recentSearchStore = container.resolve(RecentSearchStore.self)

        let appDetailBuilder: AppDetailBuilder = DefaultAppDetailBuilder(
            iTunesClient: iTunesClient,
            cache: cache,
            imageLoader: imageLoader
        )
        let seeAllBuilder: SeeAllBuilder = DefaultSeeAllBuilder(
            iTunesClient: iTunesClient,
            imageLoader: imageLoader,
            appDetail: appDetailBuilder
        )

        let todayBuilder = DefaultTodayBuilder(appDetail: appDetailBuilder)
        let gamesBuilder = DefaultGamesBuilder(
            iTunesClient: iTunesClient,
            imageLoader: imageLoader,
            appDetail: appDetailBuilder,
            seeAll: seeAllBuilder
        )
        let appsBuilder = DefaultAppsBuilder(
            iTunesClient: iTunesClient,
            imageLoader: imageLoader,
            appDetail: appDetailBuilder,
            seeAll: seeAllBuilder
        )
        let arcadeBuilder = DefaultArcadeBuilder(appDetail: appDetailBuilder)
        let searchBuilder = DefaultSearchBuilder(
            iTunesClient: iTunesClient,
            recentSearchStore: recentSearchStore,
            imageLoader: imageLoader,
            appDetail: appDetailBuilder
        )

        // 탭 순서: [Today | Games | Apps | Arcade | Search]
        let tabs: [(title: String, symbol: String, root: UIViewController)] = [
            ("투데이", "doc.text.image", todayBuilder.build()),
            ("게임", "gamecontroller", gamesBuilder.build()),
            ("앱", "square.stack.3d.up", appsBuilder.build()),
            ("아케이드", "arcade.stick", arcadeBuilder.build()),
            ("검색", "magnifyingglass", searchBuilder.build()),
        ]

        let controllers = tabs.map { tab -> UIViewController in
            let nav = UINavigationController(rootViewController: tab.root)
            nav.tabBarItem = UITabBarItem(
                title: tab.title,
                image: UIImage(systemName: tab.symbol),
                selectedImage: nil
            )
            return nav
        }

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
