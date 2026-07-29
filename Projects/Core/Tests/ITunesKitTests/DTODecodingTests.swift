//
//  DTODecodingTests.swift
//  ITunesKitTests
//
//  Created by groot on 7/29/26.
//

import Testing
import Foundation
@testable import ITunesKit

@Suite("실응답 픽스처 DTO 디코딩")
struct DTODecodingTests {
    private let decoder = JSONDecoder()

    @Test("Search 응답 디코딩")
    func decodeSearch() throws {
        let data = try FixtureLoader.data("search")
        let response = try decoder.decode(ITunesSearchResponse.self, from: data)
        #expect(response.resultCount == response.results.count)
        #expect(!response.results.isEmpty)
        let first = try #require(response.results.first)
        #expect(first.trackId > 0)
        #expect(!first.trackName.isEmpty)
        // genres 는 문자열 배열(실응답 관측).
        #expect(first.genres != nil)
    }

    @Test("Lookup 응답 디코딩(단일 결과)")
    func decodeLookup() throws {
        let data = try FixtureLoader.data("lookup")
        let response = try decoder.decode(ITunesSearchResponse.self, from: data)
        #expect(response.resultCount == 1)
        let app = try #require(response.results.first)
        #expect(app.trackId == 362057947)
        // 상세 필드가 옵셔널이라도 실응답에는 존재.
        #expect(app.description != nil)
        #expect(app.screenshotUrls != nil)
    }

    @Test("RSS top-free 디코딩(genres 비어도 안전)")
    func decodeRSSTopFree() throws {
        let data = try FixtureLoader.data("rss-topfree")
        let response = try decoder.decode(RSSFeedResponse.self, from: data)
        #expect(!response.feed.results.isEmpty)
        let entry = try #require(response.feed.results.first)
        #expect(!entry.id.isEmpty)
        #expect(!entry.name.isEmpty)
        #expect(!entry.artworkUrl100.isEmpty)
        // top-free 실응답은 genres 가 비어 있음 → 빈 배열로 안전 디코딩되어야 함.
        #expect(entry.genres.isEmpty)
    }

    @Test("RSS top-paid 디코딩(genres 객체 포함)")
    func decodeRSSTopPaid() throws {
        let data = try FixtureLoader.data("rss-toppaid")
        let response = try decoder.decode(RSSFeedResponse.self, from: data)
        let withGenre = response.feed.results.first { !$0.genres.isEmpty }
        let entry = try #require(withGenre, "top-paid 에는 genres 있는 항목이 있어야 함")
        let genre = try #require(entry.genres.first)
        #expect(!genre.name.isEmpty)
        // 실응답은 genreId 도 포함.
        #expect(genre.genreId != nil)
    }
}
