//
//  AppCoordinator.swift
//  AppUIKit
//
//  Created by groot on 8/13/26.
//

import UIKit
import AppDetailInterface
import SeeAll
import SeeAllInterface

/// 루트 코디네이터. 인프라를 1회 생성하고, **탭별 네비게이션 스택과 Router 를 소유**하며,
/// 각 플로우 코디네이터에 Router 를 주입해 `start()` 로 시작시킨 뒤 `UITabBarController` 로 배치한다.
///
/// 딥링크(`handle(_:)`)와 모달 설정 플로우(자식 코디네이터 attach/detach)의 진입점이기도 하다.
///
/// 탭 순서: [투데이 | 게임 | 앱 | 아케이드 | 검색]
@MainActor
final class AppCoordinator {
    let tabBarController = UITabBarController()

    private let factory = FlowCoordinatorFactory(infra: .make())

    /// 플로우 코디네이터(=router 사용처)를 앱 수명 동안 유지한다 — 피처 VC 는 router 를 약참조하므로.
    private var flows: [Coordinator] = []
    /// 탭별 네비게이션 스택. 탭바 배치와 딥링크 목적지 push 에 재사용한다.
    private var navigationControllers: [UINavigationController] = []
    /// 탭별 Router. 딥링크가 목적지를 해당 탭 스택에 push 할 때 사용한다.
    private var routers: [NavigationRouter] = []

    /// 모달·자식 플로우 코디네이터 생명주기 관리.
    private(set) var children: [Coordinator] = []

    private enum Tab {
        static let today = 0
        static let apps = 2
    }

    private struct TabSpec {
        let title: String
        let symbol: String
        let make: (Router) -> Coordinator
    }

    func start() {
        let tabs: [TabSpec] = [
            TabSpec(title: "투데이", symbol: "doc.text.image", make: factory.makeToday),
            TabSpec(title: "게임", symbol: "gamecontroller", make: factory.makeGames),
            TabSpec(title: "앱", symbol: "square.stack.3d.up", make: factory.makeApps),
            TabSpec(title: "아케이드", symbol: "arcade.stick", make: factory.makeArcade),
            TabSpec(title: "검색", symbol: "magnifyingglass", make: factory.makeSearch),
        ]

        for tab in tabs {
            let navigationController = UINavigationController()
            navigationController.tabBarItem = UITabBarItem(
                title: tab.title,
                image: UIImage(systemName: tab.symbol),
                selectedImage: nil
            )
            let router = NavigationRouter(navigationController: navigationController)
            let flow = tab.make(router)
            flow.start()

            navigationControllers.append(navigationController)
            routers.append(router)
            flows.append(flow)
        }

        tabBarController.viewControllers = navigationControllers
        installSettingsEntry()

        let requested = LaunchArguments.initialTab
        if requested > 0, requested < navigationControllers.count {
            tabBarController.selectedIndex = requested
        }
    }

    // MARK: - Deep link

    /// URL 을 파싱해 적절한 탭을 선택하고, 그 탭 router 로 목적지를 push 한다.
    /// 딥링크도 일반 이동과 같은 목적지 조립(AppDetail/SeeAll 빌더)을 경유한다.
    func handle(_ url: URL) {
        guard let deepLink = DeepLinkParser.parse(url) else { return }

        switch deepLink {
        case let .appDetail(id):
            let router = selectTab(Tab.apps)
            router.push(factory.makeAppDetailBuilder().build(appID: id), animated: true)
        case let .chart(kind, genreID):
            // 앱 탭 플로우 코디네이터를 SeeAll 상향 이벤트(앱 선택 → 상세) 처리기로 재사용한다.
            guard let seeAllRouting = flows[Tab.apps] as? SeeAllRouting else { return }
            let router = selectTab(Tab.apps)
            let input = SeeAllInput(title: title(for: kind), feed: kind.feedKind, genreID: genreID)
            let viewController = DefaultSeeAllBuilder(
                iTunesClient: factory.infra.iTunesClient,
                imageLoader: factory.infra.imageLoader,
                router: seeAllRouting
            ).build(input: input)
            router.push(viewController, animated: true)
        }
    }

    @discardableResult
    private func selectTab(_ index: Int) -> Router {
        if index < navigationControllers.count {
            tabBarController.selectedIndex = index
        }
        return routers[index]
    }

    private func title(for kind: DeepLinkChartKind) -> String {
        switch kind {
        case .topFree: "인기 무료 앱"
        case .topPaid: "인기 유료 앱"
        }
    }

    // MARK: - Settings modal flow

    /// 투데이 탭 루트 VC 우상단에 설정 진입 버튼을 App 측에서 붙인다(피처 VC 코드 변경 아님).
    private func installSettingsEntry() {
        guard Tab.today < navigationControllers.count,
              let root = navigationControllers[Tab.today].viewControllers.first else { return }
        root.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "person.circle"),
            style: .plain,
            target: self,
            action: #selector(showSettings)
        )
    }

    @objc private func showSettings() {
        presentSettings()
    }

    /// 설정 모달 진입점. 우상단 버튼 탭과 스크린샷용 런치 인자가 공유한다.
    func presentSettings() {
        let presentingRouter = routers[Tab.today]
        let settings = SettingsCoordinator(parentRouter: presentingRouter)
        attach(child: settings)
        settings.start()
    }

    // MARK: - Child lifecycle

    func attach(child coordinator: Coordinator) {
        children.append(coordinator)
        coordinator.onFinish = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }
            remove(child: coordinator)
        }
    }

    func remove(child coordinator: Coordinator) {
        children.removeAll { $0 === coordinator }
    }
}

// MARK: - 딥링크 차트 종류 → 피처 입력 매핑

private extension DeepLinkChartKind {
    var feedKind: ChartFeedKind {
        switch self {
        case .topFree: .topFree
        case .topPaid: .topPaid
        }
    }
}
