//
//  DefaultChartRepositoryTests.swift
//  SeeAllTests
//
//  Created by groot on 7/30/26.
//

import Testing
import Foundation
import ITunesKit
import SeeAllInterface
@testable import SeeAll

@Suite("DefaultChartRepository")
struct DefaultChartRepositoryTests {

    @Test("ChartFeedKind → ITunesKit ChartFeed 변환 + limit 전달")
    func passesFeedAndLimit() async throws {
        let client = MockITunesClient(entries: [])
        let repository = DefaultChartRepository(client: client)

        _ = try await repository.chart(feed: .topPaid, limit: 42)

        #expect(client.receivedFeed == .topPaid)
        #expect(client.receivedLimit == 42)
    }

    @Test("DTO 를 SeeAllItem 으로 매핑해 반환")
    func mapsEntriesToItems() async throws {
        let entries = try TestSupport.entries(named: "rss-topfree")
        let client = MockITunesClient(entries: entries)
        let repository = DefaultChartRepository(client: client)

        let items = try await repository.chart(feed: .topFree, limit: 50)

        #expect(items.count == entries.count)
        #expect(items.first?.rank == 1)
    }
}
