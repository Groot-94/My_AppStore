//
//  ExampleComposition.swift
//  SearchExample
//
//  Created by groot on 7/29/26.
//

import UIKit
import Persistence
import ITunesKitTesting
import Search
import AppDetailTesting

/// Search 단독 실행 조립. 오프라인 픽스처 스텁으로 네트워크 없이 구동한다.
/// 타 피처(AppDetail) 계약은 `MockAppDetailBuilder` 를 주입한다.
@MainActor
struct ExampleComposition {
    func makeRootViewController() -> UIViewController {
        let cache: Cache = DefaultCache()
        let builder = DefaultSearchBuilder(
            iTunesClient: StubITunesClient(),
            recentSearchStore: DefaultRecentSearchStore(),
            imageLoader: DefaultImageLoader(cache: cache),
            appDetail: MockAppDetailBuilder()
        )
        return builder.build()
    }
}
