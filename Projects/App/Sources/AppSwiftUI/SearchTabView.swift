//
//  SearchTabView.swift
//  AppSwiftUI
//
//  Created by groot on 8/9/26.
//

import SwiftUI

/// 검색 탭. `NavigationStack` 경로를 소유하고 화면 생성은 주입받은 클로저에 위임한다.
///
/// 구체 피처 타입을 모르므로 Search/AppDetail 의 조립 방식이 바뀌어도 이 뷰는 그대로다.
struct SearchTabView: View {
    let makeSearch: @MainActor (_ onSelectApp: @escaping (Int) -> Void) -> AnyView
    let makeAppDetail: @MainActor (_ appID: Int) -> AnyView

    @State private var path: [Int] = []

    var body: some View {
        NavigationStack(path: $path) {
            makeSearch { appID in path.append(appID) }
                .navigationDestination(for: Int.self) { appID in
                    makeAppDetail(appID)
                }
        }
        .task {
            if let appID = LaunchArguments.detailAppID {
                path = [appID]
            }
        }
    }
}
