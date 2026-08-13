//
//  GamesFlowCoordinator.swift
//  App
//
//  Created by groot on 8/13/26.
//

import UIKit
import AppDetailInterface
import Games
import GamesInterface
import SeeAll
import SeeAllInterface

/// 게임 플로우. `GamesRouting`/`SeeAllRouting` 상향 이벤트를 앱 상세·모두 보기 push 로 바꾼다.
///
/// 차트 종류(`GamesChartKind`)→`ChartFeedKind` 매핑과 `SeeAllInput` 조립이 여기서 일어난다.
/// 게임 필터용 genreID(6014)는 피처가 방출하는 값을 그대로 전달한다.
/// 라우트를 하나라도 추가하면 이 타입이 컴파일 실패하므로 App 이 처리를 누락할 수 없다.
@MainActor
final class GamesFlowCoordinator: Coordinator, AppDetailPresenting, GamesRouting, SeeAllRouting {
    var onFinish: (() -> Void)?
    let router: Router
    let appDetailBuilder: AppDetailBuilder

    private let infra: AppInfra

    init(router: Router, infra: AppInfra, appDetailBuilder: AppDetailBuilder) {
        self.router = router
        self.infra = infra
        self.appDetailBuilder = appDetailBuilder
    }

    func start() {
        let root = DefaultGamesBuilder(
            iTunesClient: infra.iTunesClient,
            imageLoader: infra.imageLoader,
            router: self
        ).build()
        router.setRoot(root)
    }

    private func pushSeeAll(title: String, feed: ChartFeedKind, genreID: Int?) {
        let input = SeeAllInput(title: title, feed: feed, genreID: genreID)
        let viewController = DefaultSeeAllBuilder(
            iTunesClient: infra.iTunesClient,
            imageLoader: infra.imageLoader,
            router: self
        ).build(input: input)
        router.push(viewController, animated: true)
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

private extension GamesChartKind {
    var chartFeedKind: ChartFeedKind {
        switch self {
        case .topFree: .topFree
        case .topPaid: .topPaid
        }
    }
}
