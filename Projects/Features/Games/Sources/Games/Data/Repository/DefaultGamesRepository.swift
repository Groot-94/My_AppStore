//
//  DefaultGamesRepository.swift
//  Games
//
//  Created by groot on 7/29/26.
//

import Foundation
import ITunesKit

/// `GamesRepository` 기본 구현. RSS 차트를 장르 정보 포함해 매핑하고, 추천은 Lookup 배치로 보강한다.
public struct DefaultGamesRepository: GamesRepository {
    private let client: ITunesClient
    private let bundle: Bundle

    public init(client: ITunesClient, bundle: Bundle? = nil) {
        self.client = client
        self.bundle = bundle ?? .module
    }

    public func chart(feed: GamesChartFeed, limit: Int) async throws -> [ChartItem] {
        let entries = try await client.chart(feed.asChartFeed, limit: limit)
        return GamesMapper.chartItems(entries)
    }

    public func featured() async throws -> [FeaturedApp] {
        let curation = GamesCurationDataSource.featured(bundle: bundle)
        guard !curation.isEmpty else { return [] }
        let dtos = try await client.lookup(ids: curation.map(\.id))
        return GamesMapper.featured(dtos, curation: curation)
    }

    public func categories() -> [Category] {
        GamesCurationDataSource.categories
    }
}

extension GamesChartFeed {
    var asChartFeed: ChartFeed {
        switch self {
        case .topFree: return .topFree
        case .topPaid: return .topPaid
        }
    }
}
