//
//  GameGenrePolicyTests.swift
//  GamesTests
//
//  Created by groot on 7/30/26.
//

import Testing
import Foundation
import ITunesKit
@testable import Games

@Suite("GameGenrePolicy")
struct GameGenrePolicyTests {

    @Test("게임 필터: genreId 6014 / 이름 매칭 항목만 남기고 rank 재부여")
    func filtersGamesAndReranks() throws {
        let items = GamesMapper.chartItems(try TestSupport.entries(named: "rss-games"))
        let games = GameGenrePolicy.gamesOnly(items)

        #expect(games.map(\.id) == [1229016807, 431946152])
        #expect(games.map(\.rank) == [1, 2])
    }

    @Test("빈 genres 항목은 게임 판별 불가로 제외")
    func excludesEmptyGenres() throws {
        let items = GamesMapper.chartItems(try TestSupport.entries(named: "rss-games"))
        let games = GameGenrePolicy.gamesOnly(items)
        #expect(games.contains { $0.id == 999999999 } == false)
    }

    @Test("게임이 없는 차트(top-paid 픽스처)는 빈 결과")
    func nonGamesChartYieldsEmpty() throws {
        let items = GamesMapper.chartItems(try TestSupport.entries(named: "rss-toppaid"))
        let games = GameGenrePolicy.gamesOnly(items)
        #expect(games.isEmpty)
    }
}
