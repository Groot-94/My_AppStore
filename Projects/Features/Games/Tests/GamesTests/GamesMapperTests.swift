//
//  GamesMapperTests.swift
//  GamesTests
//
//  Created by groot on 7/29/26.
//

import Testing
import Foundation
import ITunesKit
@testable import Games

@Suite("GamesMapper")
struct GamesMapperTests {

    @Test("게임 필터: genreId 6014 / 이름 매칭 항목만 남기고 rank 재부여")
    func filtersGamesAndReranks() throws {
        let entries = try TestSupport.entries(named: "rss-games")
        let items = GamesMapper.gameChartItems(entries)

        #expect(items.map(\.id) == [1229016807, 431946152])
        #expect(items.map(\.rank) == [1, 2])
    }

    @Test("빈 genres 항목은 게임 판별 불가로 제외")
    func excludesEmptyGenres() throws {
        let entries = try TestSupport.entries(named: "rss-games")
        let items = GamesMapper.gameChartItems(entries)
        #expect(items.contains { $0.id == 999999999 } == false)
    }

    @Test("게임이 없는 차트(top-paid 픽스처)는 빈 결과")
    func nonGamesChartYieldsEmpty() throws {
        let entries = try TestSupport.entries(named: "rss-toppaid")
        let items = GamesMapper.gameChartItems(entries)
        #expect(items.isEmpty)
    }

    @Test("추천 매핑: lookup DTO 와 큐레이션 tagline 병합")
    func featuredMergesTagline() throws {
        let dtos = try TestSupport.lookupDTOs(named: "lookup")
        let curation = [FeaturedCuration(id: 362057947, tagline: "게임 태그")]
        let featured = GamesMapper.featured(dtos, curation: curation)
        #expect(featured.count == 1)
        #expect(featured.first?.tagline == "게임 태그")
    }
}
