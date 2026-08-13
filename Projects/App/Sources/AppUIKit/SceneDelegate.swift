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

        // 콜드 스타트 딥링크(앱이 URL 로 실행된 경우).
        connectionOptions.urlContexts.forEach { appCoordinator.handle($0.url) }

        // 스크린샷·테스트용: 런치 인자로 받은 딥링크도 동일한 처리 경로로 흘려보낸다.
        if let url = LaunchArguments.deepLink {
            appCoordinator.handle(url)
        }
        if LaunchArguments.presentSettings {
            appCoordinator.presentSettings()
        }
    }

    /// 실행 중 딥링크(앱이 이미 떠 있을 때 URL 수신).
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        URLContexts.forEach { appCoordinator.handle($0.url) }
    }
}
