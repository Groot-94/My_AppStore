//
//  AppTab.swift
//  AppSwiftUI
//
//  Created by groot on 8/9/26.
//

import SwiftUI

/// 탭 하나의 명세. 조립은 Composition Root 가 끝내고 뷰는 표시만 한다.
///
/// `content` 를 `AnyView` 로 지운 덕에 `RootTabView` 는 어떤 피처가 SwiftUI 네이티브이고
/// 어떤 피처가 UIKit 인터롭인지 알지 못한다.
struct AppTab: Identifiable {
    let id: Int
    let title: String
    let symbol: String
    let content: AnyView
}
