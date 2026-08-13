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
    ///
    /// 탭(=UIKit 인터롭 스택)은 `App.init()` 에서 만들지 않는다 — 앱 구동 전 이른 시점에 UIKit
    /// 뷰컨트롤러를 조립하면 일부 iOS 버전에서 내부 배열이 준비되지 않아 크래시한다.
    /// `RootTabView` 가 화면 진입 시점(`.task`, SceneDelegate 와 동일 타이밍)에 조립한다.
    private let composition = AppComposition()

    var body: some Scene {
        WindowGroup {
            RootTabView(composition: composition)
                .onOpenURL { composition.handle($0) }
        }
    }
}
