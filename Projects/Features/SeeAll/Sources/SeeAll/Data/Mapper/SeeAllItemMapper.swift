//
//  SeeAllItemMapper.swift
//  SeeAll
//
//  Created by groot on 7/29/26.
//

import Foundation
import ITunesKit

/// `RSSEntryDTO` → `SeeAllItem` 변환기.
///
/// RSS `id` 는 문자열이므로 `Int` 로 변환한다(실패 항목은 제외). rank 는 배열 순서(index+1).
/// 게임 필터(genreID)는 RSS `genres` 원본이 필요해 여기서 수행한다.
enum SeeAllItemMapper {
    /// genreID 필터 없이 순위 그대로 매핑.
    static func map(_ entries: [RSSEntryDTO]) -> [SeeAllItem] {
        rankedItems(from: entries)
    }

    /// genreID 필터 적용 후 rank 재부여.
    /// 빈 `genres` 항목은 매칭 불가로 제외한다(RSS top-free 는 genres 가 비어 옴).
    static func map(_ entries: [RSSEntryDTO], genreID: Int) -> [SeeAllItem] {
        let filtered = entries.filter { entry in
            entry.genres.contains { GenreMatch.matches($0, genreID: genreID) }
        }
        return rankedItems(from: filtered)
    }

    private static func rankedItems(from entries: [RSSEntryDTO]) -> [SeeAllItem] {
        var rank = 0
        return entries.compactMap { entry in
            guard let id = Int(entry.id) else { return nil }
            rank += 1
            return SeeAllItem(
                rank: rank,
                id: id,
                name: entry.name,
                artistName: entry.artistName,
                artworkURL: URL(string: entry.artworkUrl100),
                genre: entry.genres.first?.name ?? ""
            )
        }
    }
}

/// RSS 장르 매칭 규칙: genreId 일치 또는 이름에 "Games" 포함.
enum GenreMatch {
    static let gamesGenreID = 6014

    static func matches(_ genre: RSSGenreDTO, genreID: Int) -> Bool {
        if let raw = genre.genreId, Int(raw) == genreID { return true }
        if genreID == gamesGenreID {
            return genre.name.localizedCaseInsensitiveContains("Games")
                || genre.name.contains("게임")
        }
        return false
    }
}
