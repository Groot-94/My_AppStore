//
//  LoadAppsFeedUseCase.swift
//  Apps
//
//  Created by groot on 7/29/26.
//

import Foundation
import CoreKit

/// Apps 피드 로드 UseCase 계약.
public protocol LoadAppsFeedUseCase: Sendable {
    /// 차트 2종 병렬 + 추천 lookup 을 조립해 반환한다.
    /// - Throws: 세 섹션이 모두 실패한 경우에만 `CoreError.notFound`.
    func execute() async throws -> AppsFeed
}

/// 기본 구현. 섹션은 독립적으로 병렬 로드하며, 개별 실패는 빈 섹션으로 흡수한다(부분 성공).
public struct DefaultLoadAppsFeedUseCase: LoadAppsFeedUseCase {
    private let repository: AppsRepository
    /// API 에서 가져올 차트 항목 수(표시는 상위 N 개만 사용).
    private let fetchLimit: Int

    public init(repository: AppsRepository, fetchLimit: Int = 20) {
        self.repository = repository
        self.fetchLimit = fetchLimit
    }

    public func execute() async throws -> AppsFeed {
        let categories = repository.categories()

        async let free = section { try await repository.chart(feed: .topFree, limit: fetchLimit) }
        async let paid = section { try await repository.chart(feed: .topPaid, limit: fetchLimit) }
        async let featured = section { try await repository.featured() }

        let feed = AppsFeed(
            featured: await featured,
            topFree: await free,
            topPaid: await paid,
            categories: categories
        )

        // 정적 카테고리만 남고 원격 섹션이 전부 비면 전체 실패로 간주.
        if feed.isEmpty { throw CoreError.notFound }
        return feed
    }

    /// 개별 섹션 실패를 빈 배열로 흡수(부분 성공 허용).
    private func section<T>(_ work: () async throws -> [T]) async -> [T] {
        (try? await work()) ?? []
    }
}
