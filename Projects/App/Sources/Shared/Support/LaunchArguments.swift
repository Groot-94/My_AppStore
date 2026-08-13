//
//  LaunchArguments.swift
//  App
//
//  Created by groot on 8/9/26.
//

import Foundation

/// 스크린샷·UITest 용 런치 인자. 흩어져 있던 `UserDefaults` 직접 접근을 한곳에 모은다.
///
/// NSArgumentDomain 은 값을 문자열로 저장하므로 정수는 `integer(forKey:)` 로 읽는다.
enum LaunchArguments {
    /// `-initialTab <index>` — 시작 탭.
    static var initialTab: Int {
        UserDefaults.standard.integer(forKey: "initialTab")
    }

    /// `-searchTerm <text>` — 검색 탭 진입 시 미리 채울 검색어.
    static var searchTerm: String? {
        UserDefaults.standard.string(forKey: "searchTerm")
    }

    /// `-detailAppID <id>` — 검색 탭에 앱 상세를 바로 push.
    static var detailAppID: Int? {
        let value = UserDefaults.standard.integer(forKey: "detailAppID")
        return value > 0 ? value : nil
    }

    /// `-deepLink <url>` — 콜드 스타트 시 딥링크 URL 을 실제 처리 경로로 그대로 흘려보낸다(스크린샷용).
    static var deepLink: URL? {
        UserDefaults.standard.string(forKey: "deepLink").flatMap(URL.init(string:))
    }

    /// `-presentSettings YES` — 시작 직후 설정 모달을 실제 진입 경로로 present 한다(스크린샷용).
    static var presentSettings: Bool {
        UserDefaults.standard.bool(forKey: "presentSettings")
    }
}
