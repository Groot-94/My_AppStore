//
//  SearchResultItemMapperTests.swift
//  SearchTests
//
//  Created by groot on 7/29/26.
//

import Testing
import Foundation
import ITunesKit
@testable import Search

@Suite("SearchResultItemMapper")
struct SearchResultItemMapperTests {

    private func loadSearchDTOs() throws -> [ITunesAppDTO] {
        let bundle = Bundle(for: BundleToken.self)
        let url = try #require(bundle.url(forResource: "search", withExtension: "json"))
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(ITunesSearchResponse.self, from: data).results
    }

    @Test("픽스처(카카오 검색) 매핑 — 첫 항목 필드 검증")
    func mapsFixtureFirstItem() throws {
        let dtos = try loadSearchDTOs()
        let items = SearchResultItemMapper.map(dtos)
        #expect(items.count == 3)

        let first = try #require(items.first)
        #expect(first.id == 362057947)
        #expect(first.name == "카카오톡 KakaoTalk")
        #expect(first.sellerName == "Kakao Corp.")
        #expect(first.genre == "Social Networking")
        #expect(first.price == "무료")
        #expect(first.rating > 3.4 && first.rating < 3.5)
        #expect(first.ratingCount == 844631)
        #expect(first.iconURL?.absoluteString.hasSuffix("512x512bb.jpg") == true)
    }

    @Test("평점/가격/장르 누락 시 안전 기본값(0, price nil)")
    func fillsSafeDefaults() throws {
        // 필수 필드(trackId/trackName)만 있는 최소 DTO.
        let json = Data(#"{"trackId": 42, "trackName": "Bare App"}"#.utf8)
        let dto = try JSONDecoder().decode(ITunesAppDTO.self, from: json)

        let item = SearchResultItemMapper.map(dto)
        #expect(item.id == 42)
        #expect(item.name == "Bare App")
        #expect(item.rating == 0)
        #expect(item.ratingCount == 0)
        #expect(item.price == nil)
        #expect(item.genre.isEmpty)
        #expect(item.sellerName.isEmpty)
        #expect(item.iconURL == nil)
    }

    @Test("sellerName 없으면 artistName 폴백")
    func fallsBackToArtistName() throws {
        let json = Data(#"{"trackId": 1, "trackName": "A", "artistName": "Artist"}"#.utf8)
        let dto = try JSONDecoder().decode(ITunesAppDTO.self, from: json)
        let item = SearchResultItemMapper.map(dto)
        #expect(item.sellerName == "Artist")
    }

    @Test("primaryGenreName 없으면 genres 첫 항목 폴백")
    func fallsBackToGenresFirst() throws {
        let json = Data(#"{"trackId": 1, "trackName": "A", "genres": ["소셜 네트워킹", "기타"]}"#.utf8)
        let dto = try JSONDecoder().decode(ITunesAppDTO.self, from: json)
        let item = SearchResultItemMapper.map(dto)
        #expect(item.genre == "소셜 네트워킹")
    }

    private final class BundleToken {}
}
