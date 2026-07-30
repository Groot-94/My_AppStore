//
//  GamesMapper.swift
//  Games
//
//  Created by groot on 7/29/26.
//

import Foundation
import ITunesKit

/// RSS/Lookup DTO → Games 엔티티 변환기(DTO→엔티티 변환만; 게임 필터는 Domain 정책).
enum GamesMapper {
    /// RSS 차트를 장르 정보를 포함한 `ChartItem` 로. rank 는 배열 순서(index+1), id String→Int.
    static func chartItems(_ entries: [RSSEntryDTO]) -> [ChartItem] {
        var rank = 0
        return entries.compactMap { entry -> ChartItem? in
            guard let id = Int(entry.id) else { return nil }
            rank += 1
            return ChartItem(
                rank: rank,
                id: id,
                name: entry.name,
                artistName: entry.artistName,
                artworkURL: URL(string: entry.artworkUrl100),
                genres: entry.genres.map { Genre(id: $0.genreId.flatMap(Int.init), name: $0.name) }
            )
        }
    }

    static func featured(_ dtos: [ITunesAppDTO], curation: [FeaturedCuration]) -> [FeaturedApp] {
        let byID = Dictionary(dtos.map { ($0.trackId, $0) }, uniquingKeysWith: { first, _ in first })
        return curation.compactMap { entry in
            guard let dto = byID[entry.id] else { return nil }
            return FeaturedApp(
                id: dto.trackId,
                name: dto.trackName,
                tagline: entry.tagline,
                artworkURL: artworkURL(from: dto)
            )
        }
    }

    private static func artworkURL(from dto: ITunesAppDTO) -> URL? {
        let candidate = dto.artworkUrl512 ?? dto.artworkUrl100 ?? dto.artworkUrl60
        return candidate.flatMap(URL.init(string:))
    }
}
