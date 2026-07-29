//
//  LoadAppsFeedUseCaseTests.swift
//  AppsTests
//
//  Created by groot on 7/29/26.
//

import Testing
import Foundation
import CoreKit
@testable import Apps

@Suite("DefaultLoadAppsFeedUseCase")
struct LoadAppsFeedUseCaseTests {

    @Test("전 섹션 성공 시 loaded 로 모두 조립")
    func allSectionsSucceed() async throws {
        let repo = MockAppsRepository(
            free: .success([TestSupport.chartItem(rank: 1, id: 1)]),
            paid: .success([TestSupport.chartItem(rank: 1, id: 2)]),
            featured: .success([TestSupport.featured(id: 3)])
        )
        let useCase = DefaultLoadAppsFeedUseCase(repository: repo)
        let feed = try await useCase.execute()

        #expect(feed.topFree.count == 1)
        #expect(feed.topPaid.count == 1)
        #expect(feed.featured.count == 1)
        #expect(feed.categories.isEmpty == false)
    }

    @Test("차트 하나만 실패해도 나머지는 표시(부분 성공)")
    func partialFailureKeepsSuccessfulSections() async throws {
        let repo = MockAppsRepository(
            free: .success([TestSupport.chartItem(rank: 1, id: 1)]),
            paid: .failure,
            featured: .success([TestSupport.featured(id: 3)])
        )
        let useCase = DefaultLoadAppsFeedUseCase(repository: repo)
        let feed = try await useCase.execute()

        #expect(feed.topFree.count == 1)
        #expect(feed.topPaid.isEmpty)
        #expect(feed.featured.count == 1)
    }

    @Test("추천만 실패하면 추천 섹션만 숨김")
    func featuredFailureHidesOnlyFeatured() async throws {
        let repo = MockAppsRepository(
            free: .success([TestSupport.chartItem(rank: 1, id: 1)]),
            paid: .success([TestSupport.chartItem(rank: 1, id: 2)]),
            featured: .failure
        )
        let useCase = DefaultLoadAppsFeedUseCase(repository: repo)
        let feed = try await useCase.execute()

        #expect(feed.featured.isEmpty)
        #expect(feed.topFree.isEmpty == false)
        #expect(feed.topPaid.isEmpty == false)
    }

    @Test("원격 섹션 전부 실패면 notFound(전체 실패)")
    func allRemoteFailuresThrow() async {
        let repo = MockAppsRepository(free: .failure, paid: .failure, featured: .failure)
        let useCase = DefaultLoadAppsFeedUseCase(repository: repo)
        await #expect(throws: CoreError.self) {
            _ = try await useCase.execute()
        }
    }
}
