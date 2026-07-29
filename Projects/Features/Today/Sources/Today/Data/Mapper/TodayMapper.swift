//
//  TodayMapper.swift
//  Today
//
//  Created by groot on 7/29/26.
//

import Foundation
import ITunesKit

/// Lookup DTO → Today 엔티티 변환기.
enum TodayMapper {
    /// Lookup DTO 를 요청 ID 순서대로 `TodayAppSummary` 로. lookup 에 없는 ID 는 제외.
    static func summaries(_ dtos: [ITunesAppDTO], ids: [Int]) -> [TodayAppSummary] {
        let byID = Dictionary(dtos.map { ($0.trackId, $0) }, uniquingKeysWith: { first, _ in first })
        return ids.compactMap { id in
            guard let dto = byID[id] else { return nil }
            return TodayAppSummary(
                id: dto.trackId,
                name: dto.trackName,
                genre: dto.primaryGenreName ?? dto.genres?.first ?? "",
                iconURL: artworkURL(from: dto),
                priceText: priceText(from: dto)
            )
        }
    }

    private static func artworkURL(from dto: ITunesAppDTO) -> URL? {
        let candidate = dto.artworkUrl512 ?? dto.artworkUrl100 ?? dto.artworkUrl60
        return candidate.flatMap(URL.init(string:))
    }

    private static func priceText(from dto: ITunesAppDTO) -> String {
        if let price = dto.price, price <= 0 { return "받기" }
        return dto.formattedPrice ?? "받기"
    }
}
