//
//  ArcadeMapper.swift
//  Arcade
//
//  Created by groot on 7/29/26.
//

import Foundation
import ITunesKit

/// Lookup DTO → Arcade 엔티티 변환기.
enum ArcadeMapper {
    /// Lookup DTO 를 요청 ID 순서대로 `ArcadeGame` 으로. lookup 에 없는 ID 는 제외.
    static func games(_ dtos: [ITunesAppDTO], ids: [Int]) -> [ArcadeGame] {
        let byID = Dictionary(dtos.map { ($0.trackId, $0) }, uniquingKeysWith: { first, _ in first })
        return ids.compactMap { id in
            guard let dto = byID[id] else { return nil }
            return ArcadeGame(
                id: dto.trackId,
                name: dto.trackName,
                genre: dto.primaryGenreName ?? dto.genres?.first ?? "",
                artworkURL: artworkURL(from: dto)
            )
        }
    }

    private static func artworkURL(from dto: ITunesAppDTO) -> URL? {
        let candidate = dto.artworkUrl512 ?? dto.artworkUrl100 ?? dto.artworkUrl60
        return candidate.flatMap(URL.init(string:))
    }
}
