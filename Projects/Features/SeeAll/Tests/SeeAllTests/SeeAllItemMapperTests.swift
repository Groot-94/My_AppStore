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

    @Test("RSS 장르 id/name 을 엔티티 genres 로 보존")
    func preservesGenres() throws {
        let json = Data(#"""
        {"feed":{"results":[
        {"artistName":"A","id":"1","name":"G","artworkUrl100":"https://e.com/x.png",
         "genres":[{"name":"Games","genreId":"6014"}]}
        ]}}
        """#.utf8)
        let entries = try JSONDecoder().decode(RSSFeedResponse.self, from: json).feed.results
        let items = SeeAllItemMapper.map(entries)
        #expect(items.first?.genres == [Genre(id: 6014, name: "Games")])
        #expect(items.first?.genre == "Games")
    }
}
