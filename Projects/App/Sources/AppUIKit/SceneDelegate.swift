//
//  SceneDelegate.swift
//  AppUIKit
//
//  Created by groot on 7/29/26.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    /// 루트 코디네이터(=플로우 router 소유자)를 앱 수명 동안 유지한다(피처 VC 는 router 를 약참조).
    private let appCoordinator = AppCoordinator()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        appCoordinator.start()
        window.rootViewController = appCoordinator.tabBarController
        window.makeKeyAndVisible()
        self.window = window
    }
}
