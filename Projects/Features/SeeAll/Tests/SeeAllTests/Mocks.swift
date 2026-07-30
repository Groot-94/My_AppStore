//
//  Mocks.swift
//  SeeAllTests
//
//  Created by groot on 7/29/26.
//

import Foundation
import Testing
import ITunesKit
import SeeAllInterface
@testable import SeeAll

/// 결과/에러를 주입할 수 있는 `ChartRepository` 목. 수신 인자를 기록한다.
final class MockChartRepository: ChartRepository, @unchecked Sendable {
    enum Outcome: Sendable {
        case success([SeeAllItem])
        case failure
    }

    private let lock = NSLock()
    private let outcome: Outcome
    private(set) var receivedFeed: ChartFeedKind?
    private(set) var receivedLimit: Int?

    init(outcome: Outcome) {
        self.outcome = outcome
    }

    func chart(feed: ChartFeedKind, limit: Int) async throws -> [SeeAllItem] {
        lock.withLock {
            receivedFeed = feed
            receivedLimit = limit
        }
        switch outcome {
        case let .success(items): return items
        case .failure: throw MockError.network
        }
    }
}

/// chart 응답을 주입하는 `ITunesClient` 목(chart 만 의미 있음). 전달된 feed/limit 을 기록.
final class MockITunesClient: ITunesClient, @unchecked Sendable {
    private let entries: [RSSEntryDTO]
    private(set) var receivedFeed: ChartFeed?
    private(set) var receivedLimit: Int?

    init(entries: [RSSEntryDTO]) {
        self.entries = entries
    }

    func search(term: String, genreID: Int?, limit: Int) async throws -> [ITunesAppDTO] { [] }
    func lookup(ids: [Int]) async throws -> [ITunesAppDTO] { [] }
    func chart(_ feed: ChartFeed, limit: Int) async throws -> [RSSEntryDTO] {
        receivedFeed = feed
        receivedLimit = limit
        return entries
    }
}

enum MockError: Error { case network }

enum TestSupport {
    static func item(
        rank: Int,
        id: Int,
        name: String = "App",
        genres: [Genre] = [Genre(id: 6014, name: "Games")]
    ) -> SeeAllItem {
        SeeAllItem(rank: rank, id: id, name: name, artistName: "Artist", artworkURL: nil, genres: genres)
    }

    static func entries(named name: String) throws -> [RSSEntryDTO] {
        let bundle = Bundle(for: BundleToken.self)
        let url = try #require(bundle.url(forResource: name, withExtension: "json"))
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(RSSFeedResponse.self, from: data).feed.results
    }

    private final class BundleToken {}
}
