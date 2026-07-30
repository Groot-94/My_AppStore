//
//  LoadArcadeFeedUseCaseTests.swift
//  ArcadeTests
//
//  Created by groot on 7/29/26.
//

import Testing
import Foundation
import CoreKit
@testable import Arcade

@Suite("DefaultLoadArcadeFeedUseCase")
struct LoadArcadeFeedUseCaseTests {

    @Test("정상 조립: 섹션별 순서 유지")
    func assemblesSections() async throws {
        let repo = MockArcadeRepository(
            curation: TestSupport.curation(newGameIDs: [1, 2], popularIDs: [3]),
            games: .success([TestSupport.game(id: 1), TestSupport.game(id: 2), TestSupport.game(id: 3)])
        )
        let feed = try await DefaultLoadArcadeFeedUseCase(repository: repo).execute()

        #expect(feed.newGames.map(\.id) == [1, 2])
        #expect(feed.popular.map(\.id) == [3])
        #expect(feed.hero.title == "Apple Arcade")
    }

    @Test("Lookup 실패 항목은 제외(부분 실패)")
    func excludesMissingGames() async throws {
        let repo = MockArcadeRepository(
            curation: TestSupport.curation(newGameIDs: [1, 2, 3], popularIDs: []),
            games: .success([TestSupport.game(id: 1), TestSupport.game(id: 3)])
        )
        let feed = try await DefaultLoadArcadeFeedUseCase(repository: repo).execute()
        #expect(feed.newGames.map(\.id) == [1, 3])
    }

    @Test("빈 큐레이션(참조 게임 없음)은 빈 피드로 반환")
    func emptyCurationYieldsEmptyFeed() async throws {
        let repo = MockArcadeRepository(
            curation: TestSupport.curation(newGameIDs: [], popularIDs: []),
            games: .success([])
        )
        let feed = try await DefaultLoadArcadeFeedUseCase(repository: repo).execute()
        #expect(feed.isEmpty)
        #expect(feed.hero.title == "Apple Arcade")
    }

    @Test("큐레이션 자체가 없으면(파싱 실패) notFound")
    func missingCurationThrows() async {
        let repo = MockArcadeRepository(curation: nil)
        await #expect(throws: CoreError.self) {
            _ = try await DefaultLoadArcadeFeedUseCase(repository: repo).execute()
        }
    }

    @Test("lookup 실패면 히어로만 있는 빈 피드로 흡수(전체 실패 아님)")
    func lookupFailureYieldsHeroOnlyFeed() async throws {
        let repo = MockArcadeRepository(
            curation: TestSupport.curation(newGameIDs: [1], popularIDs: []),
            games: .failure
        )
        let feed = try await DefaultLoadArcadeFeedUseCase(repository: repo).execute()
        #expect(feed.newGames.isEmpty)
        #expect(feed.popular.isEmpty)
        #expect(feed.hero.title == "Apple Arcade")
    }
}
