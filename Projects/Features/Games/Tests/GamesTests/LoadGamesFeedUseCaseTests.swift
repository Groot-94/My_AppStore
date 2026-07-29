//
//  LoadGamesFeedUseCaseTests.swift
//  GamesTests
//
//  Created by groot on 7/29/26.
//

import Testing
import Foundation
import CoreKit
@testable import Games

@Suite("DefaultLoadGamesFeedUseCase")
struct LoadGamesFeedUseCaseTests {

    @Test("전 섹션 성공 시 모두 조립")
    func allSectionsSucceed() async throws {
        let repo = MockGamesRepository(
            free: .success([TestSupport.chartItem(rank: 1, id: 1)]),
            paid: .success([TestSupport.chartItem(rank: 1, id: 2)]),
            featured: .success([TestSupport.featured(id: 3)])
        )
        let feed = try await DefaultLoadGamesFeedUseCase(repository: repo).execute()
        #expect(feed.topFree.count == 1)
        #expect(feed.topPaid.count == 1)
        #expect(feed.featured.count == 1)
    }

    @Test("차트 하나만 실패해도 부분 성공")
    func partialFailure() async throws {
        let repo = MockGamesRepository(
            free: .success([TestSupport.chartItem(rank: 1, id: 1)]),
            paid: .failure,
            featured: .success([TestSupport.featured(id: 3)])
        )
        let feed = try await DefaultLoadGamesFeedUseCase(repository: repo).execute()
        #expect(feed.topFree.count == 1)
        #expect(feed.topPaid.isEmpty)
    }

    @Test("원격 전부 실패면 notFound")
    func allRemoteFailuresThrow() async {
        let repo = MockGamesRepository(free: .failure, paid: .failure, featured: .failure)
        await #expect(throws: CoreError.self) {
            _ = try await DefaultLoadGamesFeedUseCase(repository: repo).execute()
        }
    }
}
