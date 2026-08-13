//
//  AppsFlowCoordinator.swift
//  App
//
//  Created by groot on 8/13/26.
//

import UIKit
import AppDetailInterface
import Apps
import AppsInterface
import SeeAll
import SeeAllInterface

/// 앱 플로우. `AppsRouting`/`SeeAllRouting` 상향 이벤트를 앱 상세·모두 보기 push 로 바꾼다.
///
/// 차트 종류(`AppsChartKind`)→`ChartFeedKind` 매핑과 `SeeAllInput` 조립이 여기서 일어난다.
/// 라우트를 하나라도 추가하면 이 타입이 컴파일 실패하므로 App 이 처리를 누락할 수 없다.
@MainActor
final class AppsFlowCoordinator: Coordinator, AppDetailPresenting, AppsRouting, SeeAllRouting {
    let navigationController: UINavigationController
    let appDetailBuilder: AppDetailBuilder

    private let infra: AppInfra

    init(navigationController: UINavigationController, infra: AppInfra, appDetailBuilder: AppDetailBuilder) {
        self.navigationController = navigationController
        self.infra = infra
        self.appDetailBuilder = appDetailBuilder
    }

    func start() {
        let root = DefaultAppsBuilder(
            iTunesClient: infra.iTunesClient,
            imageLoader: infra.imageLoader,
            router: self
        ).build()
        navigationController.setViewControllers([root], animated: false)
    }

    private func pushSeeAll(title: String, feed: ChartFeedKind, genreID: Int?) {
        let input = SeeAllInput(title: title, feed: feed, genreID: genreID)
        let viewController = DefaultSeeAllBuilder(
            iTunesClient: infra.iTunesClient,
            imageLoader: infra.imageLoader,
            router: self
        ).build(input: input)
        navigationController.pushViewController(viewController, animated: true)
    }

    // MARK: - AppsRouting

    func appsDidSelectApp(id: Int) { pushAppDetail(id: id) }

    func appsDidRequestSeeAll(title: String, kind: AppsChartKind, genreID: Int?) {
        pushSeeAll(title: title, feed: kind.chartFeedKind, genreID: genreID)
    }

    // MARK: - SeeAllRouting

    func seeAllDidSelectApp(id: Int) { pushAppDetail(id: id) }
}

// MARK: - 차트 종류 매핑 (App 이 SeeAll 입력으로 변환하는 지점)

private extension AppsChartKind {
    var chartFeedKind: ChartFeedKind {
        switch self {
        case .topFree: .topFree
        case .topPaid: .topPaid
        }
    }
}
