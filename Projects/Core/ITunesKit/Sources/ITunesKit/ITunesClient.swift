//
//  ITunesClient.swift
//  ITunesKit
//
//  Created by groot on 7/29/26.
//

import Foundation
import CoreKit
import Networking

/// iTunes 차트 피드 종류.
public enum ChartFeed: String, Sendable {
    case topFree = "top-free"
    case topPaid = "top-paid"
}

// 호출 계약을 API 3종별로 나눈다(ISP).
//
// 피처는 자기가 실제로 쓰는 계약에만 의존한다 — AppDetail/Today/Arcade 는 `AppLookup`,
// Search 는 `AppSearching`, SeeAll 은 `ChartFeeding` 만 안다. 덕분에 각 피처의 테스트 더블도
// 쓰지 않는 메서드를 구현하지 않는다.

/// 키워드 검색(iTunes Search API).
public protocol AppSearching: Sendable {
    func search(term: String, genreID: Int?, limit: Int) async throws -> [ITunesAppDTO]
}

/// 앱 ID 배치 조회(iTunes Lookup API).
public protocol AppLookup: Sendable {
    func lookup(ids: [Int]) async throws -> [ITunesAppDTO]
}

/// 인기 차트 조회(Apple Marketing RSS).
public protocol ChartFeeding: Sendable {
    func chart(_ feed: ChartFeed, limit: Int) async throws -> [RSSEntryDTO]
}

/// 세 계약을 모두 제공하는 iTunes 클라이언트.
/// 이 타입을 아는 것은 Composition Root 뿐이며, 피처에는 좁은 계약으로 주입된다.
public protocol ITunesClient: AppSearching, AppLookup, ChartFeeding {}
