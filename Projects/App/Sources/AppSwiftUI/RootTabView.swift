//
//  RootTabView.swift
//  AppSwiftUI
//
//  Created by groot on 8/4/26.
//

import SwiftUI

/// 루트 탭 화면. 탭 선택 상태만 소유하고, 무엇이 들어오는지는 알지 못한다.
///
/// 탭은 `App.init` 이 아니라 화면 진입 시점(`.task`)에 `AppComposition` 이 조립한다 —
/// UIKit 인터롭 스택을 앱 구동 전 이른 시점에 만들면 일부 iOS 버전에서 크래시하기 때문.
struct RootTabView: View {
    let composition: AppComposition

    @State private var tabs: [AppTab] = []
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            ForEach(tabs) { tab in
                tab.content
                    .tabItem { Label(tab.title, systemImage: tab.symbol) }
                    .tag(tab.id)
            }
        }
        // 딥링크가 요청한 탭으로 전환한다.
        .onChange(of: composition.selectedTab.id) { _, newValue in
            if let newValue, tabs.indices.contains(newValue) {
                selection = newValue
            }
        }
        // 화면 진입 시점(앱 구동 후)에 1회 조립한다.
        .task {
            guard tabs.isEmpty else { return }
            let built = composition.makeTabs()
            let requested = LaunchArguments.initialTab
            if built.indices.contains(requested) { selection = requested }
            tabs = built
        }
    }
}
