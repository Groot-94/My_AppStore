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
    private let client: AppLookup & ChartFeeding
    private let bundle: Bundle

    public init(client: AppLookup & ChartFeeding, bundle: Bundle? = nil) {
        self.client = client
        self.bundle = bundle ?? .module
    }

    public func chart(feed: AppsChartFeed, limit: Int) async throws -> [ChartItem] {
        let entries = try await client.chart(feed.asChartFeed, limit: limit)
        return AppsMapper.chartItems(entries)
    }

    public func featured() async throws -> [FeaturedApp] {
        let curation = AppsCurationDataSource.featured(bundle: bundle)
        guard !curation.isEmpty else { return [] }
        let dtos = try await client.lookup(ids: curation.map(\.id))
        return AppsMapper.featured(dtos, curation: curation)
    }

    public func categories() -> [Category] {
        AppsCurationDataSource.categories
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
