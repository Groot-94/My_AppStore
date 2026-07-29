//
//  AppsMapper.swift
//  Apps
//
//  Created by groot on 7/29/26.
//

import Foundation
import ITunesKit

/// RSS/Lookup DTO → Apps 엔티티 변환기.
enum AppsMapper {
    /// RSS 차트 항목 → `ChartItem`. rank 는 배열 순서(index+1), id 는 String→Int(실패 제외).
    static func chartItems(_ entries: [RSSEntryDTO]) -> [ChartItem] {
        var rank = 0
        return entries.compactMap { entry in
            guard let id = Int(entry.id) else { return nil }
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

    /// Lookup DTO 를 큐레이션 tagline 과 병합해 `FeaturedApp` 로. lookup 순서와 무관하게 큐레이션 순서를 따른다.
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
