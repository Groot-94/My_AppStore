//
//  ExampleComposition.swift
//  ArcadeExample
//
//  Created by groot on 8/13/26.
//

import UIKit
import Persistence
import ITunesKitTesting
import Arcade
import ArcadeInterface

/// Arcade 단독 실행 조립. 오프라인 픽스처 스텁으로 네트워크 없이 구동한다.
/// 상향 라우팅은 no-op 스텁 router 로 흡수한다(타 피처 비의존).
@MainActor
final class ExampleComposition {
    private let router = StubRouter()

    func makeRootViewController() -> UIViewController {
        let cache: Cache = DefaultCache()
        let builder = DefaultArcadeBuilder(
            iTunesClient: StubITunesClient(),
            imageLoader: DefaultImageLoader(cache: cache),
            router: router
        )
        return builder.build()
    }
}

/// Example 전용 no-op 라우팅 스텁. 실제 네비게이션 없이 호출만 무시한다.
@MainActor
private final class StubRouter: ArcadeRouting {
    func arcadeDidSelectApp(id: Int) {}
}
