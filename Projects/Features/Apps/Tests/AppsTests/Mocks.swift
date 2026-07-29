//
//  Mocks.swift
//  AppsTests
//
//  Created by groot on 7/29/26.
//

import Foundation
import Testing
import ITunesKit
@testable import Apps

/// 섹션별 결과/실패를 독립 주입할 수 있는 `AppsRepository` 목.
final class MockAppsRepository: AppsRepository, @unchecked Sendable {
    enum Outcome<T: Sendable>: Sendable {
        case success(T)
        case failure
    }

    private let free: Outcome<[ChartItem]>
    private let paid: Outcome<[ChartItem]>
    private let featuredOutcome: Outcome<[FeaturedApp]>
    private let staticCuration: [FeaturedCuration]
    private let staticCategories: [Apps.Category]

    init(
        free: Outcome<[ChartItem]> = .success([]),
        paid: Outcome<[ChartItem]> = .success([]),
        featured: Outcome<[FeaturedApp]> = .success([]),
        curation: [FeaturedCuration] = [FeaturedCuration(id: 1, tagline: "t")],
        categories: [Apps.Category] = [Apps.Category(genreID: 6014, name: "게임", symbol: "gamecontroller")]
    ) {
        self.free = free
        self.paid = paid
        self.featuredOutcome = featured
        self.staticCuration = curation
        self.staticCategories = categories
    }

    func chart(feed: AppsChartFeed, limit: Int) async throws -> [ChartItem] {
        switch feed {
        case .topFree: return try resolve(free)
        case .topPaid: return try resolve(paid)
        }
    }

    func featured(curation: [FeaturedCuration]) async throws -> [FeaturedApp] {
        try resolve(featuredOutcome)
    }

    func curation() -> [FeaturedCuration] { staticCuration }
    func categories() -> [Apps.Category] { staticCategories }

    private func resolve<T>(_ outcome: Outcome<T>) throws -> T {
        switch outcome {
        case let .success(value): return value
        case .failure: throw MockError.network
        }
    }
}

/// chart/lookup 응답을 주입하는 `ITunesClient` 목.
final class MockITunesClient: ITunesClient, @unchecked Sendable {
    private let chartEntries: [RSSEntryDTO]
    private let lookupResult: [ITunesAppDTO]
    private(set) var lookupIDs: [Int] = []
    private let lock = NSLock()

    init(chartEntries: [RSSEntryDTO] = [], lookupResult: [ITunesAppDTO] = []) {
        self.chartEntries = chartEntries
        self.lookupResult = lookupResult
    }

    func search(term: String, genreID: Int?, limit: Int) async throws -> [ITunesAppDTO] { [] }

    func lookup(ids: [Int]) async throws -> [ITunesAppDTO] {
        lock.withLock { lookupIDs.append(contentsOf: ids) }
        return lookupResult
    }

    func chart(_ feed: ChartFeed, limit: Int) async throws -> [RSSEntryDTO] { chartEntries }
}

enum MockError: Error { case network }

enum TestSupport {
    static func chartItem(rank: Int, id: Int) -> ChartItem {
        ChartItem(rank: rank, id: id, name: "App \(id)", artistName: "Artist", artworkURL: nil, genre: "Games")
    }

    static func featured(id: Int) -> FeaturedApp {
        FeaturedApp(id: id, name: "Feat \(id)", tagline: "tag", artworkURL: nil)
    }

    static func entries(named name: String) throws -> [RSSEntryDTO] {
        let bundle = Bundle(for: BundleToken.self)
        let url = try #require(bundle.url(forResource: name, withExtension: "json"))
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(RSSFeedResponse.self, from: data).feed.results
    }

    static func lookupDTOs(named name: String) throws -> [ITunesAppDTO] {
        let bundle = Bundle(for: BundleToken.self)
        let url = try #require(bundle.url(forResource: name, withExtension: "json"))
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(ITunesSearchResponse.self, from: data).results
    }

    private final class BundleToken {}
}
