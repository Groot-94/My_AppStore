//
//  SearchTabView.swift
//  AppSwiftUI
//
//  Created by groot on 8/13/26.
//

import SwiftUI
import SearchInterface

/// 검색 탭. `SwiftUINavRouter` 경로를 소유하고 화면 생성은 주입받은 팩토리에 위임한다.
///
/// 구체 피처 타입을 모르므로 Search/AppDetail 의 조립 방식이 바뀌어도 이 뷰는 그대로다.
/// 라우팅은 피처가 `SearchRouting` 으로 방출하고, 이 뷰의 router 가 `NavigationStack` 경로로 바꾼다.
struct SearchTabView: View {
    let makeSearch: @MainActor (_ router: SearchRouting) -> AnyView
    let makeDestination: @MainActor (_ route: AppRoute) -> AnyView

    @State private var router = SwiftUINavRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            makeSearch(router)
                .navigationDestination(for: AppRoute.self) { route in
                    makeDestination(route)
                }
        }
        .task {
            if let appID = LaunchArguments.detailAppID {
                router.path = [.appDetail(appID)]
            }
        }
    }
}
