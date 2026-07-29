//
//  SeeAllItemMapperTests.swift
//  SeeAllTests
//
//  Created by groot on 7/29/26.
//

import Testing
import Foundation
import ITunesKit
@testable import SeeAll

@Suite("SeeAllItemMapper")
struct SeeAllItemMapperTests {

    @Test("rank 는 배열 순서(index+1)로 부여")
    func assignsRankByOrder() throws {
        let entries = try TestSupport.entries(named: "rss-topfree")
        let items = SeeAllItemMapper.map(entries)

        #expect(items.count == entries.count)
        #expect(items.first?.rank == 1)
        #expect(items[1].rank == 2)
        #expect(items.last?.rank == entries.count)
    }

    @Test("RSS id 문자열을 Int 로 변환")
    func convertsStringIDToInt() throws {
        let entries = try TestSupport.entries(named: "rss-topfree")
        let items = SeeAllItemMapper.map(entries)
        #expect(items.first?.id == 6743190232)
    }

    @Test("숫자가 아닌 id 항목은 제외")
    func dropsNonNumericID() throws {
        let json = Data(#"""
        {"feed":{"results":[
        {"artistName":"A","id":"NOT_A_NUMBER","name":"X","artworkUrl100":"https://e.com/x.png","genres":[]},
        {"artistName":"B","id":"42","name":"Y","artworkUrl100":"https://e.com/y.png","genres":[]}
        ]}}
        """#.utf8)
        let entries = try JSONDecoder().decode(RSSFeedResponse.self, from: json).feed.results
        let items = SeeAllItemMapper.map(entries)
        #expect(items.count == 1)
        #expect(items.first?.id == 42)
        #expect(items.first?.rank == 1)
    }

    @Test("genreID 6014 필터: 게임만 남기고 rank 재부여")
    func filtersGamesAndReranks() throws {
        let entries = try TestSupport.entries(named: "rss-games")
        let items = SeeAllItemMapper.map(entries, genreID: 6014)

        #expect(items.count == 2)
        #expect(items.map(\.id) == [1229016807, 431946152])
        #expect(items.map(\.rank) == [1, 2])
    }

    @Test("빈 genres 항목은 필터 시 제외")
    func excludesEmptyGenres() throws {
        let entries = try TestSupport.entries(named: "rss-games")
        let items = SeeAllItemMapper.map(entries, genreID: 6014)
        #expect(items.contains { $0.id == 999999999 } == false)
    }

    @Test("genre 이름 '게임'/'Games' 포함으로도 매칭")
    func matchesByGenreName() throws {
        let json = Data(#"""
        {"feed":{"results":[
        {"artistName":"A","id":"1","name":"G","artworkUrl100":"https://e.com/x.png","genres":[{"name":"Games"}]}
        ]}}
        """#.utf8)
        let entries = try JSONDecoder().decode(RSSFeedResponse.self, from: json).feed.results
        let items = SeeAllItemMapper.map(entries, genreID: 6014)
        #expect(items.count == 1)
    }
}
