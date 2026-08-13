//
//  RootTabView.swift
//  AppSwiftUI
//
//  Created by groot on 8/4/26.
//

import SwiftUI

/// 루트 탭 화면. 탭 선택 상태만 소유하고, 무엇이 들어오는지는 알지 못한다 —
/// 피처 조립은 전부 `AppComposition` 이 끝낸 뒤 `[AppTab]` 으로 넘어온다.
struct RootTabView: View {
    private let tabs: [AppTab]
    private let selectedTab: SelectedTab

    @State private var selection: Int

    init(tabs: [AppTab], selectedTab: SelectedTab) {
        self.tabs = tabs
        self.selectedTab = selectedTab
        let requested = LaunchArguments.initialTab
        _selection = State(initialValue: tabs.indices.contains(requested) ? requested : 0)
    }

    var body: some View {
        TabView(selection: $selection) {
            ForEach(tabs) { tab in
                tab.content
                    .tabItem { Label(tab.title, systemImage: tab.symbol) }
                    .tag(tab.id)
            }
        }
        // 딥링크가 요청한 탭으로 전환한다.
        .onChange(of: selectedTab.id) { _, newValue in
            if let newValue, tabs.indices.contains(newValue) {
                selection = newValue
            }
        }
    }
}
