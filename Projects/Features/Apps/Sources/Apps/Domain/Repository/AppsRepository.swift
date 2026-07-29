//
//  AppsRepository.swift
//  Apps
//
//  Created by groot on 7/29/26.
//

import Foundation

/// Apps 차트 피드 종류(Domain 소유 — ITunesKit 비의존).
public enum AppsChartFeed: Sendable {
    case topFree
    case topPaid
}

/// 추천 큐레이션 항목(정적 JSON 원본: trackId + tagline).
public struct FeaturedCuration: Sendable, Equatable {
    public let id: Int
    public let tagline: String

    public init(id: Int, tagline: String) {
        self.id = id
        self.tagline = tagline
    }
}

/// Apps 데이터 접근 계약(피처 Domain 소유, 프로토콜만).
public protocol AppsRepository: Sendable {
    /// feed 차트를 조회해 순위 항목으로 반환한다.
    func chart(feed: AppsChartFeed, limit: Int) async throws -> [ChartItem]
    /// 추천 큐레이션(정적)을 lookup 으로 보강해 추천 항목으로 반환한다(tagline 은 큐레이션 유지).
    func featured(curation: [FeaturedCuration]) async throws -> [FeaturedApp]
    /// 정적 추천 큐레이션 목록.
    func curation() -> [FeaturedCuration]
    /// 정적 카테고리 목록.
    func categories() -> [Category]
}
