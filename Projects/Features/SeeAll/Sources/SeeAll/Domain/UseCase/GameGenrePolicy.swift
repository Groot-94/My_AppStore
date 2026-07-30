//
//  GameGenrePolicy.swift
//  SeeAll
//
//  Created by groot on 7/30/26.
//

import Foundation

/// 게임 장르 판별·필터 정책(SeeAll 피처 Domain 소유).
///
/// RSS top-free 는 `genres` 가 비어 오는 경우가 흔해, 빈 장르 항목은 매칭 불가로 제외한다.
enum GameGenrePolicy {
    static let gamesGenreID = 6014

    /// `genreID` 로 필터하고 rank 를 1부터 재부여한다.
    static func filtered(_ items: [SeeAllItem], genreID: Int) -> [SeeAllItem] {
        var rank = 0
        return items.compactMap { item in
            guard item.genres.contains(where: { matches($0, genreID: genreID) }) else { return nil }
            rank += 1
            return SeeAllItem(
                rank: rank,
                id: item.id,
                name: item.name,
                artistName: item.artistName,
                artworkURL: item.artworkURL,
                genres: item.genres
            )
        }
    }

    static func matches(_ genre: Genre, genreID: Int) -> Bool {
        if let id = genre.id, id == genreID { return true }
        if genreID == gamesGenreID {
            return genre.name.localizedCaseInsensitiveContains("Games") || genre.name.contains("게임")
        }
        return false
    }
}
