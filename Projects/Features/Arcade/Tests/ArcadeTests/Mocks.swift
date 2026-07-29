//
//  Mocks.swift
//  ArcadeTests
//
//  Created by groot on 7/29/26.
//

import Foundation
import Testing
import ITunesKit
@testable import Arcade

/// 큐레이션/게임 결과를 주입할 수 있는 `ArcadeRepository` 목.
final class MockArcadeRepository: ArcadeRepository, @unchecked Sendable {
    enum Outcome: Sendable {
        case success([ArcadeGame])
        case failure
    }

    private let staticCuration: ArcadeCuration?
    private let gamesOutcome: Outcome
    private(set) var requestedIDs: [Int] = []
    private let lock = NSLock()

    init(curation: ArcadeCuration?, games: Outcome = .success([])) {
        self.staticCuration = curation
        self.gamesOutcome = games
    }

    func curation() -> ArcadeCuration? { staticCuration }

    func games(ids: [Int]) async throws -> [ArcadeGame] {
        lock.withLock { requestedIDs.append(contentsOf: ids) }
        switch gamesOutcome {
        case let .success(all):
            return all.filter { ids.contains($0.id) }
        case .failure:
            throw MockError.network
        }
    }
}

/// lookup 응답을 주입하는 `ITunesClient` 목.
final class MockITunesClient: ITunesClient, @unchecked Sendable {
    private let lookupResult: [ITunesAppDTO]
    private(set) var lookupIDs: [Int] = []
    private let lock = NSLock()

    init(lookupResult: [ITunesAppDTO] = []) {
        self.lookupResult = lookupResult
    }

    func search(term: String, genreID: Int?, limit: Int) async throws -> [ITunesAppDTO] { [] }

    func lookup(ids: [Int]) async throws -> [ITunesAppDTO] {
        lock.withLock { lookupIDs.append(contentsOf: ids) }
        return lookupResult
    }

    func chart(_ feed: ChartFeed, limit: Int) async throws -> [RSSEntryDTO] { [] }
}

enum MockError: Error { case network }

enum TestSupport {
    static let hero = ArcadeHero(title: "Apple Arcade", subtitle: "무료 체험")

    static func game(id: Int) -> ArcadeGame {
        ArcadeGame(id: id, name: "Game \(id)", genre: "게임", artworkURL: nil)
    }

    static func curation(newGameIDs: [Int], popularIDs: [Int]) -> ArcadeCuration {
        ArcadeCuration(hero: hero, newGameIDs: newGameIDs, popularIDs: popularIDs)
    }

    static func lookupDTOs(named name: String) throws -> [ITunesAppDTO] {
        let bundle = Bundle(for: BundleToken.self)
        let url = try #require(bundle.url(forResource: name, withExtension: "json"))
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(ITunesSearchResponse.self, from: data).results
    }

    private final class BundleToken {}
}
