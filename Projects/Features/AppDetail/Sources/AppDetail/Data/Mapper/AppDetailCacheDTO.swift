//
//  AppDetailCacheDTO.swift
//  AppDetail
//
//  Created by groot on 7/29/26.
//

import Foundation
import ITunesKit

/// 캐시 저장용 상세 DTO. `ITunesAppDTO` 는 `Decodable` 전용이라 그대로 재직렬화할 수 없어,
/// 상세 화면이 쓰는 필드만 추린 `Codable` 스냅샷으로 캐싱한다.
struct AppDetailCacheDTO: Codable {
    let trackId: Int
    let trackName: String
    let sellerName: String?
    let artistName: String?
    let primaryGenreName: String?
    let genres: [String]?
    let artworkUrl512: String?
    let artworkUrl100: String?
    let artworkUrl60: String?
    let screenshotUrls: [String]?
    let description: String?
    let releaseNotes: String?
    let averageUserRating: Double?
    let userRatingCount: Int?
    let formattedPrice: String?
    let version: String?
    let currentVersionReleaseDate: String?
    let releaseDate: String?
    let contentAdvisoryRating: String?
    let trackContentRating: String?
    let fileSizeBytes: String?
    let minimumOsVersion: String?
    let languageCodesISO2A: [String]?

    init(_ dto: ITunesAppDTO) {
        trackId = dto.trackId
        trackName = dto.trackName
        sellerName = dto.sellerName
        artistName = dto.artistName
        primaryGenreName = dto.primaryGenreName
        genres = dto.genres
        artworkUrl512 = dto.artworkUrl512
        artworkUrl100 = dto.artworkUrl100
        artworkUrl60 = dto.artworkUrl60
        screenshotUrls = dto.screenshotUrls
        description = dto.description
        releaseNotes = dto.releaseNotes
        averageUserRating = dto.averageUserRating
        userRatingCount = dto.userRatingCount
        formattedPrice = dto.formattedPrice
        version = dto.version
        currentVersionReleaseDate = dto.currentVersionReleaseDate
        releaseDate = dto.releaseDate
        contentAdvisoryRating = dto.contentAdvisoryRating
        trackContentRating = dto.trackContentRating
        fileSizeBytes = dto.fileSizeBytes
        minimumOsVersion = dto.minimumOsVersion
        languageCodesISO2A = dto.languageCodesISO2A
    }
}
