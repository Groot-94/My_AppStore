//
//  SeeAllItem.swift
//  SeeAll
//
//  Created by groot on 7/29/26.
//

import Foundation

/// 장르 정보(SeeAll 피처 소유 값 타입). RSS 원본의 id/name 을 그대로 보존해 Domain 필터에 쓴다.
public struct Genre: Sendable, Equatable {
    public let id: Int?
    public let name: String

    public init(id: Int?, name: String) {
        self.id = id
        self.name = name
    }
}

/// 차트 순위 목록 항목(SeeAll 피처 소유 엔티티).
public struct SeeAllItem: Sendable, Equatable, Identifiable {
    public let rank: Int
    public let id: Int
    public let name: String
    public let artistName: String
    public let artworkURL: URL?
    public let genres: [Genre]

    /// 표시용 대표 장르명(첫 장르, 없으면 빈 문자열).
    public var genre: String { genres.first?.name ?? "" }

    public init(
        rank: Int,
        id: Int,
        name: String,
        artistName: String,
        artworkURL: URL?,
        genres: [Genre]
    ) {
        self.rank = rank
        self.id = id
        self.name = name
        self.artistName = artistName
        self.artworkURL = artworkURL
        self.genres = genres
    }
}
