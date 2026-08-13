//
//  AppComposition.swift
//  AppSwiftUI
//
//  Created by groot on 8/13/26.
//

import SwiftUI
import UIKit
import AppDetail
import Search
import SearchInterface

/// 딥링크가 선택할 탭 인덱스를 `RootTabView` 에 전달하는 관찰 가능한 상태 소유자.
@MainActor
@Observable
final class SelectedTab {
    var id: Int?
}

/// SwiftUI 앱 Composition Root. 구체 피처 타입을 아는 유일한 지점이다.
///
/// 탭 순서는 UIKit 앱과 동일: [투데이 | 게임 | 앱 | 아케이드 | 검색]
/// 검색 탭만 네이티브 SwiftUI(`SwiftUINavRouter`)이고 나머지는 공유 플로우 코디네이터의 UIKit 스택을 인터롭으로 호스팅한다.
@MainActor
final class AppComposition {
    private let infra = AppInfra.make()
    private lazy var factory = FlowCoordinatorFactory(infra: infra)

    /// 인터롭 탭의 플로우 코디네이터(=router 사용처)를 앱 수명 동안 유지한다 — UIKit VC 는 router 를 약참조.
    private var children: [Coordinator] = []
    /// 인터롭 탭의 Router. 딥링크 목적지를 해당 탭 스택에 push 할 때 재사용한다.
    private var interopRouters: [Int: NavigationRouter] = [:]
    /// 딥링크로 선택할 탭을 SwiftUI `TabView` 에 전달하기 위한 상태.
    let selectedTab = SelectedTab()

    private enum Tab {
        static let apps = 2
    }

    func makeTabs() -> [AppTab] {
        [
            AppTab(id: 0, title: "투데이", symbol: "doc.text.image", content: interopTab(0, factory.makeToday)),
            AppTab(id: 1, title: "게임", symbol: "gamecontroller", content: interopTab(1, factory.makeGames)),
            AppTab(id: 2, title: "앱", symbol: "square.stack.3d.up", content: interopTab(2, factory.makeApps)),
            AppTab(id: 3, title: "아케이드", symbol: "arcade.stick", content: interopTab(3, factory.makeArcade)),
            AppTab(id: 4, title: "검색", symbol: "magnifyingglass", content: makeSearchTab()),
        ]
    }

    // MARK: - Deep link

    /// URL 을 파싱해 적절한 탭을 선택하고 그 탭 router 로 목적지를 push 한다(인터롭 탭 경유).
    func handle(_ url: URL) {
        guard let deepLink = DeepLinkParser.parse(url) else { return }

        switch deepLink {
        case let .appDetail(id):
            guard let router = interopRouters[Tab.apps] else { return }
            selectedTab.id = Tab.apps
            router.push(factory.makeAppDetailBuilder().build(appID: id), animated: true)
        case .chart:
            // 차트 딥링크는 UIKit 앱에서 처리. SwiftUI 는 최소 앱 상세만 보장한다.
            break
        }
    }

    // MARK: - UIKit 인터롭

    /// 네비게이션 스택을 생성(루트 소유)해 Router 로 감싸 코디네이터에 주입·시작하고, 그 스택을 탭 콘텐츠로 호스팅한다.
    private func interopTab(_ index: Int, _ makeCoordinator: (Router) -> Coordinator) -> AnyView {
        let navigationController = UINavigationController()
        let router = NavigationRouter(navigationController: navigationController)
        let coordinator = makeCoordinator(router)
        coordinator.start()
        children.append(coordinator)
        interopRouters[index] = router
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
