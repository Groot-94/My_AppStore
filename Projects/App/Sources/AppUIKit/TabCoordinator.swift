//
//  TabCoordinator.swift
//  AppUIKit
//
//  Created by groot on 8/13/26.
//

import UIKit
import AppDetailInterface
import SeeAllInterface
import SearchInterface
import TodayInterface
import ArcadeInterface
import AppsInterface
import GamesInterface

/// 탭 하나의 라우팅 소유자. 모든 피처 `*Routing` 을 구현하고 목적지 조립·push 를 전담한다.
///
/// 피처는 자기 `*Routing` delegate 로 상향 이벤트만 방출하고, 목적지(AppDetail/SeeAll)는
/// 이 Coordinator 만 안다. 라우트(프로토콜 메서드)를 하나라도 추가하면 이 타입이 컴파일
/// 실패하므로, App 이 처리를 누락하는 일이 컴파일 타임에 막힌다.
@MainActor
final class TabCoordinator: SearchRouting, TodayRouting, ArcadeRouting, AppsRouting, GamesRouting, SeeAllRouting {
    /// 이 탭의 네비게이션 스택. 조립 후 AppComposition 이 연결한다.
    weak var navigationController: UINavigationController?

    private let appDetailBuilder: AppDetailBuilder
    /// SeeAll VC 조립 팩토리. 조립 시점에 이 코디네이터(`self`)를 SeeAll 의 router 로 넘긴다.
    private let makeSeeAll: (SeeAllInput, SeeAllRouting) -> UIViewController

    init(
        appDetailBuilder: AppDetailBuilder,
        makeSeeAll: @escaping (SeeAllInput, SeeAllRouting) -> UIViewController
    ) {
        self.appDetailBuilder = appDetailBuilder
        self.makeSeeAll = makeSeeAll
    }

    // MARK: - App 상세로

    private func pushAppDetail(id: Int) {
        navigationController?.pushViewController(appDetailBuilder.build(appID: id), animated: true)
    }

    // MARK: - SeeAll 로

    /// 원시값(title/kind/genreID)을 SeeAll 입력으로 조립해 push. 그 SeeAll VC 의 router 도 이 탭이 소유한다.
    private func pushSeeAll(title: String, feed: ChartFeedKind, genreID: Int?) {
        let input = SeeAllInput(title: title, feed: feed, genreID: genreID)
        navigationController?.pushViewController(makeSeeAll(input, self), animated: true)
    }

    // MARK: - SearchRouting

    func searchDidSelectApp(id: Int) { pushAppDetail(id: id) }

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
