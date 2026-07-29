//
//  DefaultAppsRepository.swift
//  Apps
//
//  Created by groot on 7/29/26.
//

import Foundation
import ITunesKit

/// `AppsRepository` 기본 구현. RSS 차트 + Lookup 배치를 호출하고 DTO 를 엔티티로 매핑한다.
public struct DefaultAppsRepository: AppsRepository {
    private let client: ITunesClient
    private let bundle: Bundle

    public init(client: ITunesClient, bundle: Bundle? = nil) {
        self.client = client
        self.bundle = bundle ?? .module
    }

    public func chart(feed: AppsChartFeed, limit: Int) async throws -> [ChartItem] {
        let entries = try await client.chart(feed.asChartFeed, limit: limit)
        return AppsMapper.chartItems(entries)
    }

    public func featured(curation: [FeaturedCuration]) async throws -> [FeaturedApp] {
        guard !curation.isEmpty else { return [] }
        let dtos = try await client.lookup(ids: curation.map(\.id))
        return AppsMapper.featured(dtos, curation: curation)
    }

    public func curation() -> [FeaturedCuration] {
        AppsCuration.featured(bundle: bundle)
    }

    public func categories() -> [Category] {
        AppsCuration.categories
    }
}

extension AppsChartFeed {
    var asChartFeed: ChartFeed {
        switch self {
        case .topFree: return .topFree
        case .topPaid: return .topPaid
        }
    }
}
