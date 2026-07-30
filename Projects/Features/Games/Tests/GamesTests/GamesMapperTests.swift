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

    @Test("차트 매핑: 필터 없이 rank(순서)·id 변환, 장르 보존")
    func mapsChartWithGenres() throws {
        let entries = try TestSupport.entries(named: "rss-games")
        let items = GamesMapper.chartItems(entries)

        #expect(items.count == entries.count)
        #expect(items.first?.rank == 1)
        #expect(items.contains { $0.genres.contains { $0.id == 6014 } })
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
