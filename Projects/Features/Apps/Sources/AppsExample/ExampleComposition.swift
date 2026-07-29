//
//  ExampleComposition.swift
//  AppsExample
//
//  Created by groot on 7/29/26.
//

import UIKit
import CoreKit
import Networking
import Persistence
import ITunesKit
import Apps
import AppDetailTesting
import SeeAllTesting

/// Apps 단독 실행 조립. `-useMocks` 면 번들 픽스처 스텁, 아니면 실 API.
/// 타 피처(AppDetail/SeeAll) 계약은 양쪽 모드 공통으로 Mock 을 주입한다.
@MainActor
struct ExampleComposition {
    private var useMocks: Bool {
        CommandLine.arguments.contains("-useMocks")
    }

    private func makeITunesClient() -> ITunesClient {
        if useMocks {
            return StubITunesClient()
        }
        return DefaultITunesClient(network: URLSessionNetworkClient(), config: .korea)
    }

    func makeRootViewController() -> UIViewController {
        let cache: Cache = DefaultCache()
        let builder = DefaultAppsBuilder(
            iTunesClient: makeITunesClient(),
            imageLoader: DefaultImageLoader(cache: cache),
            appDetail: MockAppDetailBuilder(),
            seeAll: MockSeeAllBuilder()
        )
        return builder.build()
    }
}
