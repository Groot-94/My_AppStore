//
//  SeeAllItem.swift
//  SeeAll
//
//  Created by groot on 7/29/26.
//

import Foundation

/// 차트 순위 목록 항목(SeeAll 피처 소유 엔티티).
public struct SeeAllItem: Sendable, Equatable, Identifiable {
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
