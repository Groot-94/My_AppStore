//
//  SeeAllItemMapper.swift
//  SeeAll
//
//  Created by groot on 7/29/26.
//

import Foundation
import ITunesKit

/// `RSSEntryDTO` → `SeeAllItem` 변환기(DTO→엔티티 변환만).
enum SeeAllItemMapper {
    /// RSS `id` 는 문자열이므로 `Int` 로 변환한다(실패 항목은 제외). rank 는 배열 순서(index+1).
    static func map(_ entries: [RSSEntryDTO]) -> [SeeAllItem] {
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
                genres: entry.genres.map { Genre(id: $0.genreId.flatMap(Int.init), name: $0.name) }
            )
        }
    }
}
