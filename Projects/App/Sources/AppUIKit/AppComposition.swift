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

    /// 탭 하나의 명세(타이틀 + SF Symbol + 루트 뷰컨트롤러).
    private struct TabSpec {
        let title: String
        let symbol: String
        let root: UIViewController
    }

    /// 조립된 피처 Builder 묶음.
    private struct Builders {
        let today: DefaultTodayBuilder
        let games: DefaultGamesBuilder
        let apps: DefaultAppsBuilder
        let arcade: DefaultArcadeBuilder
        let search: DefaultSearchBuilder
    }

    /// Core 인프라 + 피처 Builder 조립.
    ///
    /// 서비스 로케이터 없이 초기화 주입으로만 엮는다 — 등록 지점과 사용 지점이 이 함수 안에
    /// 함께 있어 컨테이너로 얻을 게 없고, 의존 관계가 타입으로 드러난다.
    /// StoreConfig / NetworkClient 는 iTunesClient 조립에만 쓰이므로 로컬 값으로 유지한다.
    @MainActor
    private func makeBuilders() -> Builders {
        let config = StoreConfig.korea
        let networkClient: NetworkClient = URLSessionNetworkClient()
        let iTunesClient: ITunesClient = DefaultITunesClient(network: networkClient, config: config)
        let cache: Cache = DefaultCache()
        let imageLoader: ImageLoading = DefaultImageLoader(cache: cache)
        let recentSearchStore: RecentSearchStore = DefaultRecentSearchStore()

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

        return Builders(
            today: DefaultTodayBuilder(
                iTunesClient: iTunesClient,
                imageLoader: imageLoader,
                appDetail: appDetailBuilder
            ),
            games: DefaultGamesBuilder(
                iTunesClient: iTunesClient,
                imageLoader: imageLoader,
                appDetail: appDetailBuilder,
                seeAll: seeAllBuilder
            ),
            apps: DefaultAppsBuilder(
                iTunesClient: iTunesClient,
                imageLoader: imageLoader,
                appDetail: appDetailBuilder,
                seeAll: seeAllBuilder
            ),
            arcade: DefaultArcadeBuilder(
                iTunesClient: iTunesClient,
                imageLoader: imageLoader,
                appDetail: appDetailBuilder
            ),
            search: DefaultSearchBuilder(
                iTunesClient: iTunesClient,
                recentSearchStore: recentSearchStore,
                imageLoader: imageLoader,
                appDetail: appDetailBuilder
            )
        )
    }

    /// 탭 순서: [Today | Games | Apps | Arcade | Search]
    @MainActor
    private func makeTabs(from builders: Builders) -> [TabSpec] {
        [
            TabSpec(title: "투데이", symbol: "doc.text.image", root: builders.today.build()),
            TabSpec(title: "게임", symbol: "gamecontroller", root: builders.games.build()),
            TabSpec(title: "앱", symbol: "square.stack.3d.up", root: builders.apps.build()),
            TabSpec(title: "아케이드", symbol: "arcade.stick", root: builders.arcade.build()),
            TabSpec(title: "검색", symbol: "magnifyingglass", root: builders.search.build()),
        ]
    }

    @MainActor
    private func makeTabBar(tabs: [TabSpec]) -> UITabBarController {
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

    @MainActor
    func makeRootTabBarController() -> UITabBarController {
        let builders = makeBuilders()
        let tabs = makeTabs(from: builders)
        return makeTabBar(tabs: tabs)
    }
}
