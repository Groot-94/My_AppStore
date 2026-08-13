//
//  AppInfra.swift
//  App
//
//  Created by groot on 8/13/26.
//

import CoreKit
import Networking
import Persistence
import ITunesKit

/// Core 인프라. 앱 수명 동안 1회 생성해 두 앱 타깃이 공유한다.
///
/// 여기까지가 "무엇을 쓸지"의 결정이고, "무엇을 만들지"(피처 조립)는 플로우 코디네이터가 맡는다.
@MainActor
struct AppInfra {
    let iTunesClient: ITunesClient
    let cache: Cache
    let imageLoader: ImageLoading
    let recentSearchStore: RecentSearchStore

    static func make() -> AppInfra {
        let config = StoreConfig.korea
        let networkClient: NetworkClient = URLSessionNetworkClient()
        let cache: Cache = DefaultCache()
        return AppInfra(
            iTunesClient: DefaultITunesClient(network: networkClient, config: config),
            cache: cache,
            imageLoader: DefaultImageLoader(cache: cache),
            recentSearchStore: DefaultRecentSearchStore()
        )
    }
}
