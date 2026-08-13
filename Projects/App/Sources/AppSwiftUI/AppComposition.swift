//
//  AppComposition.swift
//  AppSwiftUI
//
//  Created by groot on 8/13/26.
//

import SwiftUI
import AppDetail
import Search
import SearchInterface

/// SwiftUI 앱 Composition Root. 구체 피처 타입을 아는 유일한 지점이다.
///
/// 탭 순서는 UIKit 앱과 동일: [투데이 | 게임 | 앱 | 아케이드 | 검색]
/// 검색 탭만 네이티브 SwiftUI(`SwiftUINavRouter`)이고 나머지는 공유 플로우 코디네이터의 UIKit 스택을 인터롭으로 호스팅한다.
@MainActor
final class AppComposition {
    private let infra = AppInfra.make()
    private lazy var factory = FlowCoordinatorFactory(infra: infra)

    /// 인터롭 탭의 플로우 코디네이터(=router)를 앱 수명 동안 유지한다 — UIKit VC 는 router 를 약참조.
    private var children: [Coordinator] = []

    func makeTabs() -> [AppTab] {
        [
            AppTab(id: 0, title: "투데이", symbol: "doc.text.image", content: interopTab(factory.makeToday)),
            AppTab(id: 1, title: "게임", symbol: "gamecontroller", content: interopTab(factory.makeGames)),
            AppTab(id: 2, title: "앱", symbol: "square.stack.3d.up", content: interopTab(factory.makeApps)),
            AppTab(id: 3, title: "아케이드", symbol: "arcade.stick", content: interopTab(factory.makeArcade)),
            AppTab(id: 4, title: "검색", symbol: "magnifyingglass", content: makeSearchTab()),
        ]
    }

    // MARK: - UIKit 인터롭

    /// 네비게이션 스택을 생성(루트 소유)해 코디네이터에 주입·시작하고, 그 스택을 탭 콘텐츠로 호스팅한다.
    private func interopTab(_ makeCoordinator: (UINavigationController) -> Coordinator) -> AnyView {
        let navigationController = UINavigationController()
        let coordinator = makeCoordinator(navigationController)
        coordinator.start()
        children.append(coordinator)
        return AnyView(
            UIKitFeatureView(navigationController: navigationController)
                .ignoresSafeArea()
        )
    }

    // MARK: - 네이티브 SwiftUI 검색 탭

    private func makeSearchTab() -> AnyView {
        let infra = self.infra
        return AnyView(
            SearchTabView(
                makeSearch: { router in
                    AnyView(
                        SearchSwiftUIFactory.makeView(
                            iTunesClient: infra.iTunesClient,
                            recentSearchStore: infra.recentSearchStore,
                            imageLoader: infra.imageLoader,
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

    private func makeAppDetail(appID: Int) -> AnyView {
        AnyView(
            AppDetailSwiftUIFactory.makeView(
                appID: appID,
                iTunesClient: infra.iTunesClient,
                cache: infra.cache,
                imageLoader: infra.imageLoader
            )
        )
    }
}
