//
//  AppDependencies.swift
//  AppSwiftUI
//
//  Created by groot on 8/9/26.
//

import CoreKit
import Networking
import Persistence
import ITunesKit

/// Core 인프라 조립. 앱 수명 동안 1회 생성한다.
///
/// 여기까지가 "무엇을 쓸지"의 결정이고, "무엇을 만들지"(피처 조립)는 `AppComposition` 이 맡는다.
/// 서비스 로케이터를 두지 않고 초기화 주입만 쓴다 — 의존이 타입으로 드러나고 런타임 실패가 없다.
@MainActor
struct AppDependencies {
    let iTunesClient: ITunesClient
    let cache: Cache
    let imageLoader: ImageLoading
    let recentSearchStore: RecentSearchStore

    init() {
        let config = StoreConfig.korea
        let networkClient: NetworkClient = URLSessionNetworkClient()
        iTunesClient = DefaultITunesClient(network: networkClient, config: config)

        let cache = DefaultCache()
        self.cache = cache
        imageLoader = DefaultImageLoader(cache: cache)
        recentSearchStore = DefaultRecentSearchStore()
    }
}
