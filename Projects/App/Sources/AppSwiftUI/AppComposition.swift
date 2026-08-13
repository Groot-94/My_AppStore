//
//  AppComposition.swift
//  AppSwiftUI
//
//  Created by groot on 8/13/26.
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
import SearchInterface

/// SwiftUI 앱 Composition Root. 구체 피처 타입을 아는 유일한 지점이다.
///
/// 탭 순서는 UIKit 앱과 동일: [Today | Games | Apps | Arcade | Search]
/// 검색 탭만 네이티브 SwiftUI(`SwiftUINavRouter`)이고 나머지는 UIKit 화면을 인터롭으로 호스팅하며,
/// 인터롭 탭 라우팅은 탭별 `TabCoordinator` 가 소유한다.
@MainActor
final class AppComposition {
    private let dependencies = AppDependencies()

    /// 인터롭 탭별 Coordinator(=router)를 앱 수명 동안 유지한다 — UIKit VC 는 router 를 약참조.
    private var coordinators: [TabCoordinator] = []

    func makeTabs() -> [AppTab] {
        [
            AppTab(id: 0, title: "투데이", symbol: "doc.text.image", content: uiKitTab { dependencies, coordinator in
                DefaultTodayBuilder(
                    iTunesClient: dependencies.iTunesClient,
                    imageLoader: dependencies.imageLoader,
                    router: coordinator
                ).build()
            }),
            AppTab(id: 1, title: "게임", symbol: "gamecontroller", content: uiKitTab { dependencies, coordinator in
                DefaultGamesBuilder(
                    iTunesClient: dependencies.iTunesClient,
                    imageLoader: dependencies.imageLoader,
                    router: coordinator
                ).build()
            }),
            AppTab(id: 2, title: "앱", symbol: "square.stack.3d.up", content: uiKitTab { dependencies, coordinator in
                DefaultAppsBuilder(
                    iTunesClient: dependencies.iTunesClient,
                    imageLoader: dependencies.imageLoader,
                    router: coordinator
                ).build()
            }),
            AppTab(id: 3, title: "아케이드", symbol: "arcade.stick", content: uiKitTab { dependencies, coordinator in
                DefaultArcadeBuilder(
                    iTunesClient: dependencies.iTunesClient,
                    imageLoader: dependencies.imageLoader,
                    router: coordinator
                ).build()
            }),
            AppTab(id: 4, title: "검색", symbol: "magnifyingglass", content: makeSearchTab()),
        ]
    }

    // MARK: - AppDetail / SeeAll 조립 (App 만 아는 목적지)

    private func makeAppDetail(appID: Int) -> AnyView {
        AnyView(
            AppDetailSwiftUIFactory.makeView(
                appID: appID,
                iTunesClient: dependencies.iTunesClient,
                cache: dependencies.cache,
                imageLoader: dependencies.imageLoader
            )
        )
    }

    private func makeSeeAll(input: SeeAllInput, router: SeeAllRouting) -> UIViewController {
        DefaultSeeAllBuilder(
            iTunesClient: dependencies.iTunesClient,
            imageLoader: dependencies.imageLoader,
            router: router
        ).build(input: input)
    }

    // MARK: - 네이티브 SwiftUI 검색 탭

    private func makeSearchTab() -> AnyView {
        let dependencies = self.dependencies
        return AnyView(
            SearchTabView(
                makeSearch: { router in
                    AnyView(
                        SearchSwiftUIFactory.makeView(
                            iTunesClient: dependencies.iTunesClient,
                            recentSearchStore: dependencies.recentSearchStore,
                            imageLoader: dependencies.imageLoader,
                            onSelectApp: { [weak router] id in router?.searchDidSelectApp(id: id) },
                            initialTerm: LaunchArguments.searchTerm
                        )
                    )
                },
                makeDestination: { [weak self] route in
                    switch route {
                    case let .appDetail(appID):
                        return self?.makeAppDetail(appID: appID) ?? AnyView(EmptyView())
                    }
                }
            )
        )
    }

    // MARK: - UIKit 인터롭

    /// 미마이그레이션 피처의 UIKit 화면을 탭 콘텐츠로 감싼다.
    /// 탭별 `TabCoordinator` 를 만들어 피처에 `router:` 로 주입하고, 네비게이션을 연결한다.
    private func uiKitTab(
        _ makeRoot: @escaping @MainActor (AppDependencies, TabCoordinator) -> UIViewController
    ) -> AnyView {
        let dependencies = self.dependencies
        let coordinator = TabCoordinator(
            appDetailBuilder: DefaultAppDetailBuilder(
                iTunesClient: dependencies.iTunesClient,
                cache: dependencies.cache,
                imageLoader: dependencies.imageLoader
            ),
            makeSeeAll: { [weak self] input, router in
                self?.makeSeeAll(input: input, router: router) ?? UIViewController()
            }
        )
        coordinators.append(coordinator)
        return AnyView(
            UIKitFeatureView(
                makeRoot: { makeRoot(dependencies, coordinator) },
                onNavigation: { coordinator.navigationController = $0 }
            )
            .ignoresSafeArea()
        )
    }
}
