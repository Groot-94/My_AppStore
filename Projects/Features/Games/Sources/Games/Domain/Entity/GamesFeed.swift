//
//  GamesFeed.swift
//  Games
//
//  Created by groot on 7/29/26.
//

import Foundation

/// 추천 캐러셀 항목(Games 피처 소유 엔티티).
public struct FeaturedApp: Sendable, Equatable, Identifiable {
    public let id: Int
    public let name: String
    public let tagline: String
    public let artworkURL: URL?

    public init(id: Int, name: String, tagline: String, artworkURL: URL?) {
        self.id = id
        self.name = name
        self.tagline = tagline
        self.artworkURL = artworkURL
    }
}

/// 차트 순위 항목(Games 피처 소유 엔티티).
public struct ChartItem: Sendable, Equatable, Identifiable {
    public let rank: Int
    public let id: Int
    public let name: String
    public let artistName: String
    public let artworkURL: URL?
    public let genre: String

    public init(
        rank: Int,
        id: Int,
        name: String,
        artistName: String,
        artworkURL: URL?,
        genre: String
    ) {
        self.rank = rank
        self.id = id
        self.name = name
        self.artistName = artistName
        self.artworkURL = artworkURL
        self.genre = genre
    }
}

/// 하위 카테고리 그리드 항목(정적 목록, Games 피처 소유 엔티티).
public struct Category: Sendable, Equatable, Identifiable {
    public let genreID: Int
    public let name: String
    public let symbol: String

    public var id: Int { genreID }

    public init(genreID: Int, name: String, symbol: String) {
        self.genreID = genreID
        self.name = name
        self.symbol = symbol
    }
}

/// Games 탭 피드 조립 결과.
public struct GamesFeed: Sendable, Equatable {
    public let featured: [FeaturedApp]
    public let topFree: [ChartItem]
    public let topPaid: [ChartItem]
    public let categories: [Category]

    public init(
        featured: [FeaturedApp],
        topFree: [ChartItem],
        topPaid: [ChartItem],
        categories: [Category]
    ) {
        self.featured = featured
        self.topFree = topFree
        self.topPaid = topPaid
        self.categories = categories
    }

    public var isEmpty: Bool {
        featured.isEmpty && topFree.isEmpty && topPaid.isEmpty
    }
}
