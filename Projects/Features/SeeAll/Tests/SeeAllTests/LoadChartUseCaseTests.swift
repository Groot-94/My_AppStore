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

    @Test("genreID nil 이면 Repository 결과를 그대로 반환")
    func passesThroughWhenNoGenre() async throws {
        let expected = [TestSupport.item(rank: 1, id: 1), TestSupport.item(rank: 2, id: 2)]
        let repo = MockChartRepository(outcome: .success(expected))
        let useCase = DefaultLoadChartUseCase(repository: repo, limit: 50)
        let input = SeeAllInput(title: "인기 무료 앱", feed: .topPaid, genreID: nil)

        let result = try await useCase.execute(input: input)
        #expect(result == expected)
        #expect(repo.receivedFeed == .topPaid)
        #expect(repo.receivedLimit == 50)
    }

    @Test("genreID 6014 이면 게임 필터·rank 재부여 후 반환")
    func filtersWhenGameGenre() async throws {
        let items = [
            TestSupport.item(rank: 1, id: 1, genres: [Genre(id: 6014, name: "Games")]),
            TestSupport.item(rank: 2, id: 2, genres: [Genre(id: 6005, name: "Social")]),
            TestSupport.item(rank: 3, id: 3, genres: [Genre(id: 6014, name: "Games")]),
        ]
        let repo = MockChartRepository(outcome: .success(items))
        let useCase = DefaultLoadChartUseCase(repository: repo)
        let input = SeeAllInput(title: "인기 무료 게임", feed: .topFree, genreID: 6014)

        let result = try await useCase.execute(input: input)
        #expect(result.map(\.id) == [1, 3])
        #expect(result.map(\.rank) == [1, 2])
        #expect(repo.receivedFeed == .topFree)
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
