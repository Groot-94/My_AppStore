//
//  LoadGamesFeedUseCase.swift
//  Games
//
//  Created by groot on 7/29/26.
//

import Foundation
import CoreKit

/// Games 피드 로드 UseCase 계약.
public protocol LoadGamesFeedUseCase: Sendable {
    /// 차트 2종 병렬(게임 필터 적용) + 추천 lookup 을 조립해 반환한다.
    /// - Throws: 원격 섹션이 모두 실패한 경우에만 `CoreError.notFound`.
    func execute() async throws -> GamesFeed
}

/// 기본 구현. 섹션은 독립 병렬 로드하며 개별 실패는 빈 섹션으로 흡수한다(부분 성공).
public struct DefaultLoadGamesFeedUseCase: LoadGamesFeedUseCase {
    private let repository: GamesRepository
    private let chartLimit: Int

    public init(repository: GamesRepository, chartLimit: Int = 50) {
        self.repository = repository
        self.chartLimit = chartLimit
    }

    public func execute() async throws -> GamesFeed {
        let curation = repository.curation()
        let categories = repository.categories()

        async let free = section { try await repository.chart(feed: .topFree, limit: chartLimit) }
        async let paid = section { try await repository.chart(feed: .topPaid, limit: chartLimit) }
        async let featured = section { try await repository.featured(curation: curation) }

        let feed = GamesFeed(
            featured: await featured,
            topFree: await free,
            topPaid: await paid,
            categories: categories
        )

        if feed.isEmpty { throw CoreError.notFound }
        return feed
    }

    private func section<T>(_ work: () async throws -> [T]) async -> [T] {
        (try? await work()) ?? []
    }
}
