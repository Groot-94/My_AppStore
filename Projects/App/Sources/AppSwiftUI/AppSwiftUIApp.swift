//
//  AppSwiftUIApp.swift
//  AppSwiftUI
//
//  Created by groot on 8/4/26.
//

import SwiftUI

/// SwiftUI 라이프사이클 진입점. 조립은 `AppComposition` 이 전담한다.
@main
struct AppSwiftUIApp: App {
    /// 조립은 앱 수명 동안 1회만 — 뷰 재평가로 인프라가 다시 만들어지지 않도록 값으로 들고 있는다.
    /// Composition 은 탭별 Coordinator(=router)를 소유하므로 앱 수명 동안 유지한다(VC 는 router 를 약참조).
    private let composition = AppComposition()
    private let tabs: [AppTab]

    init() {
        tabs = composition.makeTabs()
    }

    var body: some Scene {
        WindowGroup {
            RootTabView(tabs: tabs, selectedTab: composition.selectedTab)
                .onOpenURL { composition.handle($0) }
        }
    }
}
