//
//  UIKitFeatureView.swift
//  AppSwiftUI
//
//  Created by groot on 8/13/26.
//

import SwiftUI
import UIKit

/// 미마이그레이션 피처의 UIKit VC 를 SwiftUI 탭에 그대로 호스팅하는 인터롭 래퍼.
/// VC 는 `UINavigationController` 로 감싸 피처 내부 push 네비게이션을 유지한다.
///
/// 생성된 네비게이션 컨트롤러를 `onNavigation` 으로 넘겨, 탭 `TabCoordinator` 가 push 대상을 확보한다.
struct UIKitFeatureView: UIViewControllerRepresentable {
    let makeRoot: @MainActor () -> UIViewController
    let onNavigation: @MainActor (UINavigationController) -> Void

    func makeUIViewController(context: Context) -> UINavigationController {
        let nav = UINavigationController(rootViewController: makeRoot())
        onNavigation(nav)
        return nav
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
