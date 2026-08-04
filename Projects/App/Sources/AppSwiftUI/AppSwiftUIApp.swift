//
//  AppSwiftUIApp.swift
//  AppSwiftUI
//
//  Created by groot on 8/4/26.
//

import SwiftUI
import CoreKit
import Networking
import Persistence
import ITunesKit
import AppDetail
import AppDetailInterface
import SeeAll
import SeeAllInterface

/// SwiftUI 라이프사이클 Composition Root.
/// 실 클라이언트/캐시/이미지로더/최근검색 저장소를 1회 생성해 주입한다.
@main
struct AppSwiftUIApp: App {
    private let dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            RootTabView(dependencies: dependencies)
        }
    }
}

/// 앱 전역 의존 묶음. AppUIKit 의 `AppComposition.makeContainer` 와 동일한 실 구현체를 조립한다.
@MainActor
final class AppDependencies {
    let iTunesClient: ITunesClient
    let cache: Cache
    let imageLoader: ImageLoading
    let recentSearchStore: RecentSearchStore

    /// UIKit 인터롭 탭(투데이/게임/앱/아케이드)이 쓰는 기존 AppDetail/SeeAll 계약.
    let appDetailBuilder: AppDetailBuilder
    let seeAllBuilder: SeeAllBuilder

    init() {
        let config = StoreConfig.korea
        let networkClient: NetworkClient = URLSessionNetworkClient()
        iTunesClient = DefaultITunesClient(network: networkClient, config: config)

        let cache = DefaultCache()
        self.cache = cache
        imageLoader = DefaultImageLoader(cache: cache)
        recentSearchStore = DefaultRecentSearchStore()

        appDetailBuilder = DefaultAppDetailBuilder(
            iTunesClient: iTunesClient,
            cache: cache,
            imageLoader: imageLoader
        )
        seeAllBuilder = DefaultSeeAllBuilder(
            iTunesClient: iTunesClient,
            imageLoader: imageLoader,
            appDetail: appDetailBuilder
        )
    }
}
