//
//  AppComposition.swift
//  AppSwiftUI
//
//  Created by groot on 8/9/26.
//

import SwiftUI
import Today
import Games
import Apps
import Arcade
import Search
import AppDetail
import AppDetailInterface
import SeeAll
import SeeAllInterface

/// SwiftUI 앱 Composition Root. 구체 피처 타입을 아는 유일한 지점이다.
///
/// 탭 순서는 UIKit 앱과 동일: [Today | Games | Apps | Arcade | Search]
/// 검색 탭만 네이티브 SwiftUI 이고 나머지는 UIKit 화면을 인터롭으로 호스팅한다.
@MainActor
struct AppComposition {
    private let dependencies = AppDependencies()

    func makeTabs() -> [AppTab] {
        let dependencies = self.dependencies

        let appDetail: AppDetailBuilder = DefaultAppDetailBuilder(
            iTunesClient: dependencies.iTunesClient,
            cache: dependencies.cache,
            imageLoader: dependencies.imageLoader
        )
        let seeAll: SeeAllBuilder = DefaultSeeAllBuilder(
            iTunesClient: dependencies.iTunesClient,
            imageLoader: dependencies.imageLoader,
            appDetail: appDetail
        )

        return [
            AppTab(id: 0, title: "투데이", symbol: "doc.text.image", content: uiKitTab {
                DefaultTodayBuilder(
                    iTunesClient: dependencies.iTunesClient,
                    imageLoader: dependencies.imageLoader,
                    appDetail: appDetail
                ).build()
            }),
            AppTab(id: 1, title: "게임", symbol: "gamecontroller", content: uiKitTab {
                DefaultGamesBuilder(
                    iTunesClient: dependencies.iTunesClient,
                    imageLoader: dependencies.imageLoader,
                    appDetail: appDetail,
                    seeAll: seeAll
                ).build()
            }),
            AppTab(id: 2, title: "앱", symbol: "square.stack.3d.up", content: uiKitTab {
                DefaultAppsBuilder(
                    iTunesClient: dependencies.iTunesClient,
                    imageLoader: dependencies.imageLoader,
                    appDetail: appDetail,
                    seeAll: seeAll
                ).build()
            }),
            AppTab(id: 3, title: "아케이드", symbol: "arcade.stick", content: uiKitTab {
                DefaultArcadeBuilder(
                    iTunesClient: dependencies.iTunesClient,
                    imageLoader: dependencies.imageLoader,
                    appDetail: appDetail
                ).build()
            }),
            AppTab(id: 4, title: "검색", symbol: "magnifyingglass", content: makeSearchTab()),
        ]
    }

    // MARK: - 네이티브 SwiftUI

    private func makeSearchTab() -> AnyView {
        let dependencies = self.dependencies
        return AnyView(
            SearchTabView(
                makeSearch: { onSelectApp in
                    AnyView(
                        SearchSwiftUIFactory.makeView(
                            iTunesClient: dependencies.iTunesClient,
                            recentSearchStore: dependencies.recentSearchStore,
                            imageLoader: dependencies.imageLoader,
                            onSelectApp: onSelectApp,
                            initialTerm: LaunchArguments.searchTerm
                        )
                    )
                },
                makeAppDetail: { appID in
                    AnyView(
                        AppDetailSwiftUIFactory.makeView(
                            appID: appID,
                            iTunesClient: dependencies.iTunesClient,
                            cache: dependencies.cache,
                            imageLoader: dependencies.imageLoader
                        )
                    )
                }
            )
        )
    }

    // MARK: - UIKit 인터롭

    /// 미마이그레이션 피처의 UIKit 화면을 탭 콘텐츠로 감싼다.
    private func uiKitTab(_ makeRoot: @escaping @MainActor () -> UIViewController) -> AnyView {
        AnyView(UIKitFeatureView(makeRoot: makeRoot).ignoresSafeArea())
    }
}
