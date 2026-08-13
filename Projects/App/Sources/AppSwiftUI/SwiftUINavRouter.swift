//
//  SwiftUINavRouter.swift
//  AppSwiftUI
//
//  Created by groot on 8/13/26.
//

import SwiftUI
import SearchInterface
import SeeAllInterface

/// 네이티브 SwiftUI 탭의 라우트. `NavigationStack` 경로 요소로 쓰므로 Hashable — App 이 소유하는 값 타입.
///
/// 현재 네이티브 탭(검색)의 두 라우팅(Search/SeeAll)은 모두 앱 상세로 귀결되므로 `appDetail` 하나면
/// 충분하다. 새 목적지가 생기면 케이스를 추가하고, 아래 라우터가 컴파일 실패로 처리를 강제한다.
enum AppRoute: Hashable {
    case appDetail(Int)
}

/// 네이티브 검색 탭의 라우팅 소유자. 피처 `*Routing` 을 구현해 상향 이벤트를 `NavigationStack` 경로로 바꾼다.
///
/// 라우트(프로토콜 메서드)를 추가하면 이 타입이 컴파일 실패하므로 App 이 처리를 누락할 수 없다.
@MainActor
@Observable
final class SwiftUINavRouter: SearchRouting, SeeAllRouting {
    var path: [AppRoute] = []

    func searchDidSelectApp(id: Int) {
        path.append(.appDetail(id))
    }

    func seeAllDidSelectApp(id: Int) {
        path.append(.appDetail(id))
    }
}
