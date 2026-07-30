//
//  SearchResultItem.swift
//  Search
//
//  Created by groot on 7/29/26.
//

import Foundation

/// 검색 결과 목록 항목(Search 피처 소유 엔티티). 목록 표시에 필요한 필드만 갖는다.
public struct SearchResultItem: Sendable, Equatable, Identifiable {
    /// iTunes `trackId`.
    public let id: Int
    /// 앱 이름.
    public let name: String
    /// 판매자/개발사명.
    public let sellerName: String
    /// 대표 장르(예: "소셜 네트워킹").
    public let genre: String
    /// 아이콘 URL(nil 이면 플레이스홀더).
    public let iconURL: URL?
    /// 평점(0 기본).
    public let rating: Double
    /// 평점 수(0 기본).
    public let ratingCount: Int
    /// API 원본 가격 문자열(`formattedPrice`). nil 이면 표시 계층에서 "무료" 폴백.
    public let price: String?

    public init(
        id: Int,
        name: String,
        sellerName: String,
        genre: String,
        iconURL: URL?,
        rating: Double,
        ratingCount: Int,
        price: String?
    ) {
        self.id = id
        self.name = name
        self.sellerName = sellerName
        self.genre = genre
        self.iconURL = iconURL
        self.rating = rating
        self.ratingCount = ratingCount
        self.price = price
    }
}
