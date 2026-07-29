//
//  LoadTodayFeedUseCaseTests.swift
//  TodayTests
//
//  Created by groot on 7/29/26.
//

import Testing
import Foundation
import CoreKit
@testable import Today

@Suite("DefaultLoadTodayFeedUseCase")
struct LoadTodayFeedUseCaseTests {

    @Test("정상 조립: 스토리 순서 유지 + 참조 앱 채움")
    func assemblesCards() async throws {
        let repo = MockTodayRepository(
            curation: [
                TestSupport.story(id: "a", kind: .feature, appIDs: [1]),
                TestSupport.story(id: "b", kind: .list, appIDs: [2, 3]),
            ],
            summaries: .success([
                TestSupport.summary(id: 1),
                TestSupport.summary(id: 2),
                TestSupport.summary(id: 3),
            ])
        )
        let cards = try await DefaultLoadTodayFeedUseCase(repository: repo).execute()

        #expect(cards.map(\.id) == ["a", "b"])
        #expect(cards.first?.apps.count == 1)
        #expect(cards.last?.apps.map(\.id) == [2, 3])
    }

    @Test("Lookup 실패 앱은 카드에서 제외(부분 실패)")
    func excludesMissingApps() async throws {
        let repo = MockTodayRepository(
            curation: [TestSupport.story(id: "a", appIDs: [1, 2, 3])],
            summaries: .success([TestSupport.summary(id: 1), TestSupport.summary(id: 3)])
        )
        let cards = try await DefaultLoadTodayFeedUseCase(repository: repo).execute()
        #expect(cards.first?.apps.map(\.id) == [1, 3])
    }

    @Test("참조 앱이 전부 실패한 카드는 카드째 제외")
    func dropsFullyMissingCard() async throws {
        let repo = MockTodayRepository(
            curation: [
                TestSupport.story(id: "a", appIDs: [1]),
                TestSupport.story(id: "b", appIDs: [99]),
            ],
            summaries: .success([TestSupport.summary(id: 1)])
        )
        let cards = try await DefaultLoadTodayFeedUseCase(repository: repo).execute()
        #expect(cards.map(\.id) == ["a"])
    }

    @Test("모든 카드가 비면 notFound")
    func allCardsEmptyThrows() async {
        let repo = MockTodayRepository(
            curation: [TestSupport.story(id: "a", appIDs: [99])],
            summaries: .success([])
        )
        await #expect(throws: CoreError.self) {
            _ = try await DefaultLoadTodayFeedUseCase(repository: repo).execute()
        }
    }

    @Test("큐레이션이 비면 notFound")
    func emptyCurationThrows() async {
        let repo = MockTodayRepository(curation: [], summaries: .success([]))
        await #expect(throws: CoreError.self) {
            _ = try await DefaultLoadTodayFeedUseCase(repository: repo).execute()
        }
    }

    @Test("lookup 전체 실패면 throw")
    func lookupFailureThrows() async {
        let repo = MockTodayRepository(
            curation: [TestSupport.story(id: "a", appIDs: [1])],
            summaries: .failure
        )
        await #expect(throws: Error.self) {
            _ = try await DefaultLoadTodayFeedUseCase(repository: repo).execute()
        }
    }
}
