//
//  DefaultITunesClient.swift
//  ITunesKit
//
//  Created by groot on 7/29/26.
//

import Foundation
import Networking
import CoreKit

/// `ITunesClient` 기본 구현. `NetworkClient` 주입 + `StoreConfig` 로 country/lang 적용.
///
/// DTO 만 반환한다 — 엔티티 매핑은 각 피처가 소유.
public struct DefaultITunesClient: ITunesClient {
    private let network: NetworkClient
    private let config: StoreConfig

    public init(network: NetworkClient, config: StoreConfig = .korea) {
        self.network = network
        self.config = config
    }

    public func search(term: String, genreID: Int?, limit: Int) async throws -> [ITunesAppDTO] {
        let endpoint = ITunesEndpoint.search(term: term, genreID: genreID, limit: limit, config: config)
        let response = try await network.decode(ITunesSearchResponse.self, from: endpoint)
        return response.results
    }

    public func lookup(ids: [Int]) async throws -> [ITunesAppDTO] {
        guard !ids.isEmpty else { return [] }
        let endpoint = ITunesEndpoint.lookup(ids: ids, config: config)
        let response = try await network.decode(ITunesSearchResponse.self, from: endpoint)
        return response.results
    }

    public func chart(_ feed: ChartFeed, limit: Int) async throws -> [RSSEntryDTO] {
        let endpoint = ITunesEndpoint.chart(feed: feed, limit: limit, config: config)
        let response = try await network.decode(RSSFeedResponse.self, from: endpoint)
        return response.feed.results
    }
}
