//
//  ExampleComposition.swift
//  GamesExample
//
//  Created by groot on 7/29/26.
//

import UIKit
import Persistence
import ITunesKitTesting
import Games
import AppDetailTesting
import SeeAllTesting

/// Games 단독 실행 조립. 오프라인 픽스처 스텁으로 네트워크 없이 구동한다.
/// 타 피처(AppDetail/SeeAll) 계약은 Mock 을 주입한다.
@MainActor
struct ExampleComposition {
    func makeRootViewController() -> UIViewController {
        let cache: Cache = DefaultCache()
        let builder = DefaultGamesBuilder(
            iTunesClient: StubITunesClient(),
            imageLoader: DefaultImageLoader(cache: cache),
            appDetail: MockAppDetailBuilder(),
            seeAll: MockSeeAllBuilder()
        )
        return builder.build()
    }
}
