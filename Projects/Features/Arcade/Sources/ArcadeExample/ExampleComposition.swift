//
//  ExampleComposition.swift
//  ArcadeExample
//
//  Created by groot on 7/29/26.
//

import UIKit
import Persistence
import ITunesKitTesting
import Arcade
import AppDetailTesting

/// Arcade 단독 실행 조립. 오프라인 픽스처 스텁으로 네트워크 없이 구동한다.
/// 타 피처(AppDetail) 계약은 `MockAppDetailBuilder` 를 주입한다.
@MainActor
struct ExampleComposition {
    func makeRootViewController() -> UIViewController {
        let cache: Cache = DefaultCache()
        let builder = DefaultArcadeBuilder(
            iTunesClient: StubITunesClient(),
            imageLoader: DefaultImageLoader(cache: cache),
            appDetail: MockAppDetailBuilder()
        )
        return builder.build()
    }
}
