//
//  LoadChartUseCaseTests.swift
//  SeeAllTests
//
//  Created by groot on 7/29/26.
//

import Testing
import Foundation
import SeeAllInterface
@testable import SeeAll

@Suite("DefaultLoadChartUseCase")
struct LoadChartUseCaseTests {

    @Test("input feed/genreID/limit 를 Repository 로 전달하고 결과 반환")
    func forwardsInputAndReturnsResult() async throws {
        let expected = [TestSupport.item(rank: 1, id: 1), TestSupport.item(rank: 2, id: 2)]
        let repo = MockChartRepository(outcome: .success(expected))
        let useCase = DefaultLoadChartUseCase(repository: repo, limit: 50)
        let input = SeeAllInput(title: "인기 무료 게임", feed: .topFree, genreID: 6014)

        let result = try await useCase.execute(input: input)
        #expect(result == expected)
        #expect(repo.receivedFeed == .topFree)
        #expect(repo.receivedGenreID == .some(6014))
        #expect(repo.receivedLimit == 50)
    }

    @Test("genreID nil 도 그대로 전달")
    func forwardsNilGenreID() async throws {
        let repo = MockChartRepository(outcome: .success([]))
        let useCase = DefaultLoadChartUseCase(repository: repo)
        let input = SeeAllInput(title: "인기 무료 앱", feed: .topPaid, genreID: nil)

        _ = try await useCase.execute(input: input)
        #expect(repo.receivedFeed == .topPaid)
        #expect(repo.receivedGenreID == .some(Int?.none))
    }

    @Test("Repository 실패 전파")
    func propagatesFailure() async {
        let repo = MockChartRepository(outcome: .failure)
        let useCase = DefaultLoadChartUseCase(repository: repo)
        let input = SeeAllInput(title: "x", feed: .topFree, genreID: nil)
        await #expect(throws: MockError.self) {
            _ = try await useCase.execute(input: input)
        }
    }
}
