//
//  ExampleComposition.swift
//  AppDetailExample
//
//  Created by groot on 7/29/26.
//

import UIKit
import Persistence
import ITunesKitTesting
import AppDetail

/// AppDetail 단독 실행 조립. 오프라인 픽스처(lookup) 스텁으로 네트워크 없이 구동한다.
/// AppDetail 은 타 피처 계약에 의존하지 않는다.
@MainActor
struct ExampleComposition {
    /// 스텁 lookup 픽스처가 반환하는 샘플 앱(카카오톡).
    private let sampleAppID = 362057947

    func makeRootViewController() -> UIViewController {
        let cache: Cache = DefaultCache()
        let builder = DefaultAppDetailBuilder(
            iTunesClient: StubITunesClient(),
            cache: cache,
            imageLoader: DefaultImageLoader(cache: cache)
        )
        return builder.build(appID: sampleAppID)
    }
}
