//
//  AppDetail.swift
//  AppDetail
//
//  Created by groot on 7/29/26.
//

import Foundation

/// 앱 상세 엔티티(AppDetail 피처 소유). 상세 화면이 필요로 하는 전 필드를 갖는다.
public struct AppDetail: Sendable, Equatable, Identifiable {
    /// iTunes `trackId`.
    public let id: Int
    /// 앱 이름.
    public let name: String
    /// 판매자/개발사명.
    public let sellerName: String
    /// 대표 장르.
    public let genre: String
    /// 아이콘 URL(nil 이면 플레이스홀더).
    public let iconURL: URL?
    /// 스크린샷 URL 배열(비었으면 페이저 섹션 숨김).
    public let screenshotURLs: [URL]
    /// 상세 설명.
    public let description: String
    /// 새로운 기능(nil/빈 문자열이면 섹션 숨김).
    public let releaseNotes: String?
    /// 버전 문자열.
    public let version: String
    /// 최근 버전 갱신일(nil 가능).
    public let updatedAt: Date?
    /// 평균 평점(0 기본).
    public let rating: Double
    /// 평점 수(0 기본).
    public let ratingCount: Int
    /// API 원본 가격 문자열(`formattedPrice`). nil 이면 표시 계층에서 "무료" 폴백.
    public let price: String?
    /// 연령 등급(예: "4+").
    public let contentRating: String
    /// 파일 크기(바이트, 미상이면 nil).
    public let fileSizeBytes: Int64?
    /// 최소 지원 OS 버전(예: "17.0").
    public let minimumOSVersion: String
    /// 지원 언어 ISO 코드 배열.
    public let languages: [String]

    public init(
        id: Int,
        name: String,
        sellerName: String,
        genre: String,
        iconURL: URL?,
        screenshotURLs: [URL],
        description: String,
        releaseNotes: String?,
        version: String,
        updatedAt: Date?,
        rating: Double,
        ratingCount: Int,
        price: String?,
        contentRating: String,
        fileSizeBytes: Int64?,
        minimumOSVersion: String,
        languages: [String]
    ) {
        self.id = id
        self.name = name
        self.sellerName = sellerName
        self.genre = genre
        self.iconURL = iconURL
        self.screenshotURLs = screenshotURLs
        self.description = description
        self.releaseNotes = releaseNotes
        self.version = version
        self.updatedAt = updatedAt
        self.rating = rating
        self.ratingCount = ratingCount
        self.price = price
        self.contentRating = contentRating
        self.fileSizeBytes = fileSizeBytes
        self.minimumOSVersion = minimumOSVersion
        self.languages = languages
    }
}
