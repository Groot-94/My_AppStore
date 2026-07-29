//
//  Mocks.swift
//  GamesTests
//
//  Created by groot on 7/29/26.
//

import Foundation
import Testing
import ITunesKit
@testable import Games

/// 섹션별 결과/실패를 독립 주입할 수 있는 `GamesRepository` 목.
final class MockGamesRepository: GamesRepository, @unchecked Sendable {
    enum Outcome<T: Sendable>: Sendable {
        case success(T)
        case failure
    }

    private let free: Outcome<[ChartItem]>
    private let paid: Outcome<[ChartItem]>
    private let featuredOutcome: Outcome<[FeaturedApp]>
    private let staticCuration: [FeaturedCuration]
    private let staticCategories: [Games.Category]

    init(
        free: Outcome<[ChartItem]> = .success([]),
        paid: Outcome<[ChartItem]> = .success([]),
        featured: Outcome<[FeaturedApp]> = .success([]),
        curation: [FeaturedCuration] = [FeaturedCuration(id: 1, tagline: "t")],
        categories: [Games.Category] = [Games.Category(genreID: 7001, name: "액션", symbol: "bolt")]
    ) {
        self.free = free
        self.paid = paid
        self.featuredOutcome = featured
        self.staticCuration = curation
        self.staticCategories = categories
    }

    func chart(feed: GamesChartFeed, limit: Int) async throws -> [ChartItem] {
        switch feed {
        case .topFree: return try resolve(free)
        case .topPaid: return try resolve(paid)
        }
    }

    func featured(curation: [FeaturedCuration]) async throws -> [FeaturedApp] {
        try resolve(featuredOutcome)
    }

    func curation() -> [FeaturedCuration] { staticCuration }
    func categories() -> [Games.Category] { staticCategories }

    private func resolve<T>(_ outcome: Outcome<T>) throws -> T {
        switch outcome {
        case let .success(value): return value
        case .failure: throw MockError.network
        }
    }
}

enum MockError: Error { case network }

enum TestSupport {
    static func chartItem(rank: Int, id: Int) -> ChartItem {
        ChartItem(rank: rank, id: id, name: "Game \(id)", artistName: "Studio", artworkURL: nil, genre: "게임")
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
