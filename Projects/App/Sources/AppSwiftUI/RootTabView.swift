//
//  RootTabView.swift
//  AppSwiftUI
//
//  Created by groot on 8/4/26.
//

import SwiftUI
import Today
import Games
import Apps
import Arcade
import Search
import AppDetail

/// 5탭 루트. 검색 탭은 네이티브 SwiftUI(마이그레이션 완료),
/// 나머지 4탭은 기존 UIKit VC 인터롭(미마이그레이션)으로 공존한다.
struct RootTabView: View {
    let dependencies: AppDependencies

    @State private var searchPath: [Int] = []
    // 스크린샷/UITest 지원: `-initialTab <index>` 로 시작 탭 지정(없으면 0).
    @State private var selectedTab = max(0, UserDefaults.standard.integer(forKey: "initialTab"))

    var body: some View {
        TabView(selection: $selectedTab) {
            todayTab.tag(0)
            gamesTab.tag(1)
            appsTab.tag(2)
            arcadeTab.tag(3)
            searchTab.tag(4)
        }
        .task {
            // 스크린샷/UITest 지원: `-detailAppID <id>` 로 검색 탭에 상세를 바로 push.
            let detailAppID = UserDefaults.standard.integer(forKey: "detailAppID")
            if detailAppID > 0 { searchPath = [detailAppID] }
        }
    }

    // MARK: - 네이티브 SwiftUI

    private var searchTab: some View {
        NavigationStack(path: $searchPath) {
            SearchSwiftUIFactory.makeView(
                iTunesClient: dependencies.iTunesClient,
                recentSearchStore: dependencies.recentSearchStore,
                imageLoader: dependencies.imageLoader,
                onSelectApp: { appID in searchPath.append(appID) },
                initialTerm: UserDefaults.standard.string(forKey: "searchTerm")
            )
            .navigationDestination(for: Int.self) { appID in
                AppDetailSwiftUIFactory.makeView(
                    appID: appID,
                    iTunesClient: dependencies.iTunesClient,
                    cache: dependencies.cache,
                    imageLoader: dependencies.imageLoader
                )
            }
        }
        .tabItem { Label("검색", systemImage: "magnifyingglass") }
    }

    // MARK: - UIKit 인터롭

    private var todayTab: some View {
        UIKitFeatureView {
            DefaultTodayBuilder(
                iTunesClient: dependencies.iTunesClient,
                imageLoader: dependencies.imageLoader,
                appDetail: dependencies.appDetailBuilder
            ).build()
        }
        .ignoresSafeArea()
        .tabItem { Label("투데이", systemImage: "doc.text.image") }
    }

    private var gamesTab: some View {
        UIKitFeatureView {
            DefaultGamesBuilder(
                iTunesClient: dependencies.iTunesClient,
                imageLoader: dependencies.imageLoader,
                appDetail: dependencies.appDetailBuilder,
                seeAll: dependencies.seeAllBuilder
            ).build()
        }
        .ignoresSafeArea()
        .tabItem { Label("게임", systemImage: "gamecontroller") }
    }

    private var appsTab: some View {
        UIKitFeatureView {
            DefaultAppsBuilder(
                iTunesClient: dependencies.iTunesClient,
                imageLoader: dependencies.imageLoader,
                appDetail: dependencies.appDetailBuilder,
                seeAll: dependencies.seeAllBuilder
            ).build()
        }
        .ignoresSafeArea()
        .tabItem { Label("앱", systemImage: "square.stack.3d.up") }
    }

    private var arcadeTab: some View {
        UIKitFeatureView {
            DefaultArcadeBuilder(
                iTunesClient: dependencies.iTunesClient,
                imageLoader: dependencies.imageLoader,
                appDetail: dependencies.appDetailBuilder
            ).build()
        }
        .ignoresSafeArea()
        .tabItem { Label("아케이드", systemImage: "arcade.stick") }
    }
}
