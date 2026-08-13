//
//  SceneDelegate.swift
//  AppUIKit
//
//  Created by groot on 7/29/26.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    /// 탭별 Coordinator(=router)를 소유한 Composition 을 앱 수명 동안 유지한다(VC 는 router 를 약참조).
    private let composition = AppComposition()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = composition.makeRootTabBarController()
        window.makeKeyAndVisible()
        self.window = window
    }
}
