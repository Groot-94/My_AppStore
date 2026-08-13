//
//  UIKitFeatureView.swift
//  AppSwiftUI
//
//  Created by groot on 8/13/26.
//

import SwiftUI
import UIKit

/// 미마이그레이션 피처의 UIKit 네비게이션 스택을 SwiftUI 탭에 그대로 호스팅하는 인터롭 래퍼.
///
/// 스택 조립과 라우팅은 공유 플로우 코디네이터가 소유하고, 이 래퍼는 그 `UINavigationController` 만 표시한다.
struct UIKitFeatureView: UIViewControllerRepresentable {
    let navigationController: UINavigationController

    func makeUIViewController(context: Context) -> UINavigationController {
        navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
