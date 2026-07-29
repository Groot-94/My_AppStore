//
//  GamesRepository.swift
//  Games
//
//  Created by groot on 7/29/26.
//

import Foundation

/// Games 차트 피드 종류(Domain 소유 — ITunesKit 비의존).
public enum GamesChartFeed: Sendable {
    case topFree
    case topPaid
}

/// 추천 큐레이션 항목(정적 JSON 원본: trackId + tagline).
public struct FeaturedCuration: Sendable, Equatable {
    public let id: Int
    public let tagline: String

    public init(id: Int, tagline: String) {
        self.id = id
        self.tagline = tagline
    }
}

/// Games 데이터 접근 계약(피처 Domain 소유, 프로토콜만).
///
/// 차트는 RSS 결과에서 게임(genres "Games"/genreId 6014) 항목만 필터해 반환한다.
public protocol GamesRepository: Sendable {
    func chart(feed: GamesChartFeed, limit: Int) async throws -> [ChartItem]
    func featured(curation: [FeaturedCuration]) async throws -> [FeaturedApp]
    func curation() -> [FeaturedCuration]
    func categories() -> [Category]
}
