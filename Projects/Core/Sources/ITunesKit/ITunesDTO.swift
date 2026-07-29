//
//  ITunesDTO.swift
//  ITunesKit
//
//  Created by groot on 7/29/26.
//

import Foundation

/// iTunes Search/Lookup 응답 래퍼.
public struct ITunesSearchResponse: Decodable, Sendable {
    public let resultCount: Int
    public let results: [ITunesAppDTO]
}

/// Search/Lookup App 객체 DTO.
///
/// 실응답에서 자주 빠지는 필드는 옵셔널로 둔다.
/// 주의: Search/Lookup 의 `genres` 는 문자열 배열로, RSS 의 객체 배열과 형태가 다르다.
public struct ITunesAppDTO: Decodable, Sendable {
    // 식별/이름
    public let trackId: Int
    public let trackName: String
    public let bundleId: String?

    // 개발사
    public let artistName: String?
    public let sellerName: String?

    // 카테고리
    public let primaryGenreName: String?
    public let genres: [String]?
    public let genreIds: [String]?

    // 아이콘
    public let artworkUrl512: String?
    public let artworkUrl100: String?
    public let artworkUrl60: String?

    // 스크린샷
    public let screenshotUrls: [String]?
    public let ipadScreenshotUrls: [String]?

    // 설명 / 새 소식
    public let description: String?
    public let releaseNotes: String?

    // 평점 / 리뷰
    public let averageUserRating: Double?
    public let userRatingCount: Int?

    // 가격
    public let formattedPrice: String?
    public let price: Double?
    public let currency: String?

    // 버전 / 갱신일
    public let version: String?
    public let currentVersionReleaseDate: String?
    public let releaseDate: String?

    // 연령 등급
    public let contentAdvisoryRating: String?
    public let trackContentRating: String?

    // 크기 / 최소 OS (fileSizeBytes 는 실응답에서 문자열로 옴)
    public let fileSizeBytes: String?
    public let minimumOsVersion: String?

    // 지원 언어
    public let languageCodesISO2A: [String]?
}

/// RSS 차트 항목 DTO. 필드가 적다(스크린샷/설명/평점 없음).
public struct RSSEntryDTO: Decodable, Sendable {
    public let id: String
    public let name: String
    public let artistName: String
    public let artworkUrl100: String
    /// 실응답에서 비어 있는 경우가 흔해(top-free 관측) 누락 시 빈 배열로 디코딩한다.
    public let genres: [RSSGenreDTO]
    public let url: String?

    private enum CodingKeys: String, CodingKey {
        case id, name, artistName, artworkUrl100, genres, url
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        artistName = try container.decode(String.self, forKey: .artistName)
        artworkUrl100 = try container.decode(String.self, forKey: .artworkUrl100)
        genres = try container.decodeIfPresent([RSSGenreDTO].self, forKey: .genres) ?? []
        url = try container.decodeIfPresent(String.self, forKey: .url)
    }
}

/// RSS 장르 객체.
public struct RSSGenreDTO: Decodable, Sendable {
    public let name: String
    public let genreId: String?
    public let url: String?
}

/// RSS 응답 중첩 구조(`{ feed: { title, results: [...] } }`).
public struct RSSFeedResponse: Decodable, Sendable {
    public struct Feed: Decodable, Sendable {
        public let title: String?
        public let results: [RSSEntryDTO]
    }
    public let feed: Feed
}
