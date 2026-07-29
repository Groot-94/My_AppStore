//
//  AppsMapperTests.swift
//  AppsTests
//
//  Created by groot on 7/29/26.
//

import Testing
import Foundation
import ITunesKit
@testable import Apps

@Suite("AppsMapper")
struct AppsMapperTests {

    @Test("차트 매핑: rank 배열 순서, id 문자열→Int")
    func chartItemsRankAndID() throws {
        let entries = try TestSupport.entries(named: "rss-topfree")
        let items = AppsMapper.chartItems(entries)

        #expect(items.first?.rank == 1)
        #expect(items.first?.id == 6743190232)
        #expect(items.map(\.rank) == Array(1...items.count))
    }

    @Test("숫자가 아닌 id 항목 제외 + rank 연속")
    func dropsNonNumericID() throws {
        let json = Data(#"""
        {"feed":{"results":[
        {"artistName":"A","id":"BAD","name":"X","artworkUrl100":"https://e.com/x.png","genres":[]},
        {"artistName":"B","id":"7","name":"Y","artworkUrl100":"https://e.com/y.png","genres":[]},
        {"artistName":"C","id":"8","name":"Z","artworkUrl100":"https://e.com/z.png","genres":[]}
        ]}}
        """#.utf8)
        let entries = try JSONDecoder().decode(RSSFeedResponse.self, from: json).feed.results
        let items = AppsMapper.chartItems(entries)
        #expect(items.map(\.id) == [7, 8])
        #expect(items.map(\.rank) == [1, 2])
    }

    @Test("추천 매핑: lookup DTO 와 큐레이션 tagline 병합")
    func featuredMergesTagline() throws {
        let dtos = try TestSupport.lookupDTOs(named: "lookup")
        let curation = [FeaturedCuration(id: 362057947, tagline: "국민 메신저")]
        let featured = AppsMapper.featured(dtos, curation: curation)

        #expect(featured.count == 1)
        #expect(featured.first?.id == 362057947)
        #expect(featured.first?.name == "카카오톡 KakaoTalk")
        #expect(featured.first?.tagline == "국민 메신저")
        #expect(featured.first?.artworkURL != nil)
    }

    @Test("lookup 에 없는 큐레이션 ID 는 추천에서 제외")
    func featuredSkipsMissingLookup() throws {
        let dtos = try TestSupport.lookupDTOs(named: "lookup")
        let curation = [
            FeaturedCuration(id: 362057947, tagline: "있음"),
            FeaturedCuration(id: 999, tagline: "없음"),
        ]
        let featured = AppsMapper.featured(dtos, curation: curation)
        #expect(featured.map(\.id) == [362057947])
    }
}
