//
//  GamesMapper.swift
//  Games
//
//  Created by groot on 7/29/26.
//

import Foundation
import ITunesKit

/// RSS/Lookup DTO → Games 엔티티 변환기. 차트는 게임 항목만 필터 후 rank 부여.
enum GamesMapper {
    static let gamesGenreID = 6014

    /// RSS 차트에서 게임 항목만 필터해 `ChartItem` 로. rank 는 필터 후 순서(index+1), id String→Int.
    /// 빈 `genres` 항목은 게임 판별 불가로 제외한다.
    static func gameChartItems(_ entries: [RSSEntryDTO]) -> [ChartItem] {
        var rank = 0
        return entries.compactMap { entry -> ChartItem? in
            guard entry.genres.contains(where: isGamesGenre),
                  let id = Int(entry.id) else { return nil }
            rank += 1
            return ChartItem(
                rank: rank,
                id: id,
                name: entry.name,
                artistName: entry.artistName,
                artworkURL: URL(string: entry.artworkUrl100),
                genre: entry.genres.first?.name ?? ""
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

    private static func isGamesGenre(_ genre: RSSGenreDTO) -> Bool {
        if let raw = genre.genreId, Int(raw) == gamesGenreID { return true }
        return genre.name.localizedCaseInsensitiveContains("Games") || genre.name.contains("게임")
    }

    private static func artworkURL(from dto: ITunesAppDTO) -> URL? {
        let candidate = dto.artworkUrl512 ?? dto.artworkUrl100 ?? dto.artworkUrl60
        return candidate.flatMap(URL.init(string:))
    }
}
