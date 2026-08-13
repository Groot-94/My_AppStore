//
//  TabCoordinator.swift
//  AppSwiftUI
//
//  Created by groot on 8/13/26.
//

import UIKit
import AppDetailInterface
import SeeAllInterface
import TodayInterface
import ArcadeInterface
import AppsInterface
import GamesInterface

/// 인터롭(UIKit) 탭의 라우팅 소유자. UIKit 화면의 push 네비게이션을 전담한다.
///
/// 검색 탭만 네이티브 SwiftUI(`SwiftUINavRouter`)로 라우팅하고, 나머지 UIKit 인터롭 탭은
/// AppUIKit 과 동일하게 이 Coordinator 가 `UINavigationController` 로 push 한다.
/// 라우트를 하나라도 추가하면 이 타입이 컴파일 실패하므로 App 이 누락할 수 없다.
@MainActor
final class TabCoordinator: TodayRouting, ArcadeRouting, AppsRouting, GamesRouting, SeeAllRouting {
    weak var navigationController: UINavigationController?

    private let appDetailBuilder: AppDetailBuilder
    private let makeSeeAll: (SeeAllInput, SeeAllRouting) -> UIViewController

    init(
        appDetailBuilder: AppDetailBuilder,
        makeSeeAll: @escaping (SeeAllInput, SeeAllRouting) -> UIViewController
    ) {
        self.appDetailBuilder = appDetailBuilder
        self.makeSeeAll = makeSeeAll
    }

    private func pushAppDetail(id: Int) {
        navigationController?.pushViewController(appDetailBuilder.build(appID: id), animated: true)
    }

    private func pushSeeAll(title: String, feed: ChartFeedKind, genreID: Int?) {
        let input = SeeAllInput(title: title, feed: feed, genreID: genreID)
        navigationController?.pushViewController(makeSeeAll(input, self), animated: true)
    }

    // MARK: - TodayRouting

    func todayDidSelectApp(id: Int) { pushAppDetail(id: id) }

    // MARK: - ArcadeRouting

    func arcadeDidSelectApp(id: Int) { pushAppDetail(id: id) }

    // MARK: - AppsRouting

    func appsDidSelectApp(id: Int) { pushAppDetail(id: id) }

    func appsDidRequestSeeAll(title: String, kind: AppsChartKind, genreID: Int?) {
        pushSeeAll(title: title, feed: kind.chartFeedKind, genreID: genreID)
    }

    // MARK: - GamesRouting

    func gamesDidSelectApp(id: Int) { pushAppDetail(id: id) }

    func gamesDidRequestSeeAll(title: String, kind: GamesChartKind, genreID: Int?) {
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

private extension GamesChartKind {
    var chartFeedKind: ChartFeedKind {
        switch self {
        case .topFree: .topFree
        case .topPaid: .topPaid
        }
    }
}
