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

/// iTunes API 3종(Search/Lookup/RSS) 호출 계약.
public protocol ITunesClient: Sendable {
    func search(term: String, genreID: Int?, limit: Int) async throws -> [ITunesAppDTO]
    func lookup(ids: [Int]) async throws -> [ITunesAppDTO]
    func chart(_ feed: ChartFeed, limit: Int) async throws -> [RSSEntryDTO]
}
