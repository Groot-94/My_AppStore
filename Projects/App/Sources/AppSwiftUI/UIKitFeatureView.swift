//
//  UIKitFeatureView.swift
//  AppSwiftUI
//
//  Created by groot on 8/4/26.
//

import SwiftUI
import UIKit

/// 미마이그레이션 피처의 UIKit VC 를 SwiftUI 탭에 그대로 호스팅하는 인터롭 래퍼.
/// VC 는 `UINavigationController` 로 감싸 피처 내부 push 네비게이션을 유지한다.
struct UIKitFeatureView: UIViewControllerRepresentable {
    let makeRoot: @MainActor () -> UIViewController

    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(rootViewController: makeRoot())
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
