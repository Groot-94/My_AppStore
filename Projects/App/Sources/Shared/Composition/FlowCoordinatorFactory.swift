//
//  FlowCoordinatorFactory.swift
//  App
//
//  Created by groot on 8/13/26.
//

import UIKit
import AppDetail
import AppDetailInterface

/// 탭별 플로우 코디네이터를 조립하는 유일한 지점. 두 앱 타깃이 공유한다.
///
/// AppDetail 빌더 조립이 여기 한곳에 있어, 각 Composition Root 는 `factory.makeSearch($0)` 처럼
/// 네비게이션 스택만 넘기면 된다(중복 제거).
@MainActor
struct FlowCoordinatorFactory {
    let infra: AppInfra

    func makeToday(_ router: Router) -> Coordinator {
        TodayFlowCoordinator(router: router, infra: infra, appDetailBuilder: makeAppDetailBuilder())
    }

    func makeGames(_ router: Router) -> Coordinator {
        GamesFlowCoordinator(router: router, infra: infra, appDetailBuilder: makeAppDetailBuilder())
    }

    func makeApps(_ router: Router) -> Coordinator {
        AppsFlowCoordinator(router: router, infra: infra, appDetailBuilder: makeAppDetailBuilder())
    }

    func makeArcade(_ router: Router) -> Coordinator {
        ArcadeFlowCoordinator(router: router, infra: infra, appDetailBuilder: makeAppDetailBuilder())
    }

    func makeSearch(_ router: Router) -> Coordinator {
        SearchFlowCoordinator(router: router, infra: infra, appDetailBuilder: makeAppDetailBuilder())
    }

    func makeAppDetailBuilder() -> AppDetailBuilder {
        DefaultAppDetailBuilder(
            iTunesClient: infra.iTunesClient,
            cache: infra.cache,
            imageLoader: infra.imageLoader
        )
    }
}
