//
//  DefaultChartRepository.swift
//  SeeAll
//
//  Created by groot on 7/29/26.
//

import Foundation
import ITunesKit
import SeeAllInterface

/// `ChartRepository` 기본 구현. RSS 차트를 조회해 장르 정보를 포함한 항목으로 매핑한다.
public struct DefaultChartRepository: ChartRepository {
    private let client: ChartFeeding

    public init(client: ChartFeeding) {
        self.client = client
    }

    public func chart(feed: ChartFeedKind, limit: Int) async throws -> [SeeAllItem] {
        let entries = try await client.chart(feed.asChartFeed, limit: limit)
        return SeeAllItemMapper.map(entries)
    }
}

extension ChartFeedKind {
    /// Interface 소유 피드 종류 → ITunesKit 피드 종류(Data 계층 경계 변환).
    var asChartFeed: ChartFeed {
        switch self {
        case .topFree: return .topFree
        case .topPaid: return .topPaid
        }
    }
}
