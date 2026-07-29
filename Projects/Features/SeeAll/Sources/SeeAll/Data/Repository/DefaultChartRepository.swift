//
//  DefaultChartRepository.swift
//  SeeAll
//
//  Created by groot on 7/29/26.
//

import Foundation
import ITunesKit
import SeeAllInterface

/// `ChartRepository` 기본 구현. RSS 차트를 조회해 매핑하고, genreID 가 있으면 장르 필터를 적용한다.
public struct DefaultChartRepository: ChartRepository {
    private let client: ITunesClient

    public init(client: ITunesClient) {
        self.client = client
    }

    public func chart(feed: ChartFeedKind, genreID: Int?, limit: Int) async throws -> [SeeAllItem] {
        let entries = try await client.chart(feed.asChartFeed, limit: limit)
        if let genreID {
            return SeeAllItemMapper.map(entries, genreID: genreID)
        }
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
