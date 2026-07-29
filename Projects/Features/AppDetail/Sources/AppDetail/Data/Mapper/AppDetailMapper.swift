//
//  AppDetailMapper.swift
//  AppDetail
//
//  Created by groot on 7/29/26.
//

import Foundation
import ITunesKit

/// `ITunesAppDTO` → `AppDetail` 변환기.
///
/// 실응답에서 자주 빠지는 필드에 안전 기본값을 채운다(평점 0, 가격 "무료").
/// `fileSizeBytes` 는 실응답에서 문자열로 오므로 `Int64` 로 변환한다.
enum AppDetailMapper {
    static let freePriceText = "무료"

    static func map(_ dto: ITunesAppDTO) -> AppDetail {
        map(AppDetailCacheDTO(dto))
    }

    static func map(_ dto: AppDetailCacheDTO) -> AppDetail {
        AppDetail(
            id: dto.trackId,
            name: dto.trackName,
            sellerName: dto.sellerName ?? dto.artistName ?? "",
            genre: dto.primaryGenreName ?? dto.genres?.first ?? "",
            iconURL: iconURL(from: dto),
            screenshotURLs: (dto.screenshotUrls ?? []).compactMap(URL.init(string:)),
            description: dto.description ?? "",
            releaseNotes: normalizedReleaseNotes(dto.releaseNotes),
            version: dto.version ?? "",
            updatedAt: parseDate(dto.currentVersionReleaseDate ?? dto.releaseDate),
            rating: dto.averageUserRating ?? 0,
            ratingCount: dto.userRatingCount ?? 0,
            priceText: dto.formattedPrice ?? freePriceText,
            contentRating: dto.contentAdvisoryRating ?? dto.trackContentRating ?? "",
            fileSizeBytes: dto.fileSizeBytes.flatMap(Int64.init),
            minimumOSVersion: dto.minimumOsVersion ?? "",
            languages: dto.languageCodesISO2A ?? []
        )
    }

    /// 아이콘 선호 순위: 512 → 100 → 60.
    private static func iconURL(from dto: AppDetailCacheDTO) -> URL? {
        let candidate = dto.artworkUrl512 ?? dto.artworkUrl100 ?? dto.artworkUrl60
        return candidate.flatMap(URL.init(string:))
    }

    /// 공백만 남는 릴리스 노트는 nil 로 취급(섹션 숨김 판단 위임).
    private static func normalizedReleaseNotes(_ notes: String?) -> String? {
        guard let notes, !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return notes
    }

    private static func parseDate(_ raw: String?) -> Date? {
        guard let raw else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: raw)
    }
}
