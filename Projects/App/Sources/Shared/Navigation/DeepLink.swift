//
//  DeepLink.swift
//  App
//
//  Created by groot on 8/13/26.
//

import Foundation

/// 앱이 처리할 수 있는 딥링크 목적지. URL 파싱과 라우팅을 분리하기 위한 값 타입.
enum DeepLink: Equatable {
    case appDetail(id: Int)
    case chart(kind: DeepLinkChartKind, genreID: Int?)
}

/// 딥링크 차트 종류. 피처 타입(`ChartFeedKind`)과 독립적으로 App 이 소유한다.
enum DeepLinkChartKind: Equatable {
    case topFree
    case topPaid
}

/// URL → `DeepLink` 파서. 라우팅과 분리되어 순수 함수로 테스트 가능하다.
///
/// 지원 형식:
/// - `myappstore://app/{id}`      → `.appDetail`
/// - `myappstore://chart/free`    → `.chart(.topFree)`
/// - `myappstore://chart/paid`    → `.chart(.topPaid)`
///   (`?genre={id}` 로 장르 필터 선택)
enum DeepLinkParser {
    static let scheme = "myappstore"

    static func parse(_ url: URL) -> DeepLink? {
        guard url.scheme == scheme else { return nil }

        // host 가 첫 경로 요소, path 가 그 뒤. 예: myappstore://app/362057947 → host "app", path "/362057947"
        let host = url.host
        let segments = url.pathComponents.filter { $0 != "/" }

        switch host {
        case "app":
            guard let first = segments.first, let id = Int(first) else { return nil }
            return .appDetail(id: id)
        case "chart":
            guard let kind = segments.first.flatMap(chartKind(from:)) else { return nil }
            return .chart(kind: kind, genreID: genreID(from: url))
        default:
            return nil
        }
    }

    private static func chartKind(from segment: String) -> DeepLinkChartKind? {
        switch segment {
        case "free": .topFree
        case "paid": .topPaid
        default: nil
        }
    }

    private static func genreID(from url: URL) -> Int? {
        URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first { $0.name == "genre" }?
            .value
            .flatMap(Int.init)
    }
}
