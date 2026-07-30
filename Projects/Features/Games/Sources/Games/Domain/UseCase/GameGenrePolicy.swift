//
//  GameGenrePolicy.swift
//  Games
//
//  Created by groot on 7/30/26.
//

import Foundation

/// 게임 장르 판별·필터 정책(Games 피처 Domain 소유).
///
/// RSS `genres` 가 비어 오는 항목은 게임 판별 불가로 제외한다.
enum GameGenrePolicy {
    static let gamesGenreID = 6014

    /// 게임 항목만 남기고 rank 를 1부터 재부여한다.
    static func gamesOnly(_ items: [ChartItem]) -> [ChartItem] {
        var rank = 0
        return items.compactMap { item in
            guard item.genres.contains(where: isGamesGenre) else { return nil }
            rank += 1
            return ChartItem(
                rank: rank,
                id: item.id,
                name: item.name,
                artistName: item.artistName,
                artworkURL: item.artworkURL,
                genres: item.genres
            )
        }
    }

    static func isGamesGenre(_ genre: Genre) -> Bool {
        if let id = genre.id, id == gamesGenreID { return true }
        return genre.name.localizedCaseInsensitiveContains("Games") || genre.name.contains("게임")
    }
}
