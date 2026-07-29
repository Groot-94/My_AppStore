//
//  ExampleComposition.swift
//  AppDetailExample
//
//  Created by groot on 7/29/26.
//

import UIKit
import CoreKit
import Networking
import Persistence
import ITunesKit
import AppDetail

/// AppDetail 단독 실행 조립. `-useMocks` 면 번들 픽스처(lookup) 스텁, 아니면 실 API.
/// AppDetail 은 타 피처 계약에 의존하지 않는다.
@MainActor
struct ExampleComposition {
    /// 실 API 모드에서 조회할 샘플 앱(카카오톡).
    private let sampleAppID = 362057947

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
        let builder = DefaultAppDetailBuilder(
            iTunesClient: makeITunesClient(),
            cache: cache,
            imageLoader: DefaultImageLoader(cache: cache)
        )
        return builder.build(appID: sampleAppID)
    }
}
