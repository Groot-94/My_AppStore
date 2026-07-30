//
//  GameGenrePolicyTests.swift
//  SeeAllTests
//
//  Created by groot on 7/30/26.
//

import Testing
import Foundation
import ITunesKit
@testable import SeeAll

@Suite("GameGenrePolicy")
struct GameGenrePolicyTests {

    @Test("genreID 6014 필터: 게임만 남기고 rank 재부여")
    func filtersGamesAndReranks() throws {
        let items = SeeAllItemMapper.map(try TestSupport.entries(named: "rss-games"))
        let filtered = GameGenrePolicy.filtered(items, genreID: 6014)

        #expect(filtered.count == 2)
        #expect(filtered.map(\.id) == [1229016807, 431946152])
        #expect(filtered.map(\.rank) == [1, 2])
    }

    @Test("빈 genres 항목은 필터 시 제외")
    func excludesEmptyGenres() throws {
        let items = SeeAllItemMapper.map(try TestSupport.entries(named: "rss-games"))
        let filtered = GameGenrePolicy.filtered(items, genreID: 6014)
        #expect(filtered.contains { $0.id == 999999999 } == false)
    }

    @Test("genre 이름 '게임'/'Games' 포함으로도 매칭")
    func matchesByGenreName() {
        let item = SeeAllItem(
            rank: 1, id: 1, name: "G", artistName: "A", artworkURL: nil,
            genres: [Genre(id: nil, name: "Games")]
        )
        let filtered = GameGenrePolicy.filtered([item], genreID: 6014)
        #expect(filtered.count == 1)
    }
}
