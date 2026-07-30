//
//  SearchResultItemMapper.swift
//  Search
//
//  Created by groot on 7/29/26.
//

import Foundation
import ITunesKit

/// `ITunesAppDTO` → `SearchResultItem` 변환기.
///
/// 실응답에서 자주 빠지는 필드에 안전 기본값을 채운다(평점 0). 가격은 API 원본을 그대로 두고
/// "무료" 폴백은 표시 계층에서 결정한다.
enum SearchResultItemMapper {
    static func map(_ dto: ITunesAppDTO) -> SearchResultItem {
        SearchResultItem(
            id: dto.trackId,
            name: dto.trackName,
            sellerName: dto.sellerName ?? dto.artistName ?? "",
            genre: dto.primaryGenreName ?? dto.genres?.first ?? "",
            iconURL: iconURL(from: dto),
            rating: dto.averageUserRating ?? 0,
            ratingCount: dto.userRatingCount ?? 0,
            price: dto.formattedPrice
        )
    }

    static func map(_ dtos: [ITunesAppDTO]) -> [SearchResultItem] {
        dtos.map(map)
    }

    /// 아이콘 선호 순위: 512 → 100 → 60. 목록 셀은 100 로 충분하나 512 우선으로 화질 확보.
    private static func iconURL(from dto: ITunesAppDTO) -> URL? {
        let candidate = dto.artworkUrl512 ?? dto.artworkUrl100 ?? dto.artworkUrl60
        return candidate.flatMap(URL.init(string:))
    }
}
