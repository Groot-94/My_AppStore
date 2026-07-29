//
//  AppDetailMapperTests.swift
//  AppDetailTests
//
//  Created by groot on 7/29/26.
//

import Testing
import Foundation
import ITunesKit
@testable import AppDetail

@Suite("AppDetailMapper")
struct AppDetailMapperTests {

    private func loadLookupDTO() throws -> ITunesAppDTO {
        let bundle = Bundle(for: BundleToken.self)
        let url = try #require(bundle.url(forResource: "lookup", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(ITunesSearchResponse.self, from: data)
        return try #require(response.results.first)
    }

    @Test("픽스처(카카오 lookup) 매핑 — 상세 필드 검증")
    func mapsFixture() throws {
        let detail = AppDetailMapper.map(try loadLookupDTO())

        #expect(detail.id == 362057947)
        #expect(detail.name == "카카오톡 KakaoTalk")
        #expect(detail.sellerName == "Kakao Corp.")
        #expect(detail.genre == "Social Networking")
        #expect(detail.version == "26.6.4")
        #expect(detail.contentRating == "4+")
        #expect(detail.minimumOSVersion == "17.0")
        #expect(detail.rating > 3.4 && detail.rating < 3.5)
        #expect(detail.ratingCount == 844631)
        #expect(detail.priceText == "무료")
        #expect(detail.languages.contains("KO"))
        #expect(detail.releaseNotes?.isEmpty == false)
        #expect(detail.description.isEmpty == false)
        #expect(detail.updatedAt != nil)
        #expect(detail.iconURL?.absoluteString.hasSuffix("512x512bb.jpg") == true)
    }

    @Test("fileSizeBytes 문자열 → Int64 변환")
    func convertsFileSize() throws {
        let detail = AppDetailMapper.map(try loadLookupDTO())
        #expect(detail.fileSizeBytes == 538_160_128)
    }

    @Test("픽스처 스크린샷 비어 있으면 빈 배열")
    func emptyScreenshotsWhenAbsent() throws {
        let detail = AppDetailMapper.map(try loadLookupDTO())
        #expect(detail.screenshotURLs.isEmpty)
    }

    @Test("스크린샷 URL 배열 매핑")
    func mapsScreenshots() throws {
        let json = Data(#"""
        {"trackId": 1, "trackName": "A",
         "screenshotUrls": ["https://example.com/a.jpg", "https://example.com/b.jpg"]}
        """#.utf8)
        let dto = try JSONDecoder().decode(ITunesAppDTO.self, from: json)
        let detail = AppDetailMapper.map(dto)
        #expect(detail.screenshotURLs.count == 2)
    }

    @Test("누락 필드 안전 기본값(평점 0, 가격 무료, 크기 nil)")
    func fillsSafeDefaults() throws {
        let json = Data(#"{"trackId": 42, "trackName": "Bare App"}"#.utf8)
        let dto = try JSONDecoder().decode(ITunesAppDTO.self, from: json)
        let detail = AppDetailMapper.map(dto)

        #expect(detail.id == 42)
        #expect(detail.name == "Bare App")
        #expect(detail.rating == 0)
        #expect(detail.ratingCount == 0)
        #expect(detail.priceText == "무료")
        #expect(detail.genre.isEmpty)
        #expect(detail.sellerName.isEmpty)
        #expect(detail.iconURL == nil)
        #expect(detail.fileSizeBytes == nil)
        #expect(detail.releaseNotes == nil)
        #expect(detail.updatedAt == nil)
        #expect(detail.languages.isEmpty)
    }

    @Test("숫자가 아닌 fileSizeBytes 는 nil")
    func nonNumericFileSizeIsNil() throws {
        let json = Data(#"{"trackId": 1, "trackName": "A", "fileSizeBytes": "N/A"}"#.utf8)
        let dto = try JSONDecoder().decode(ITunesAppDTO.self, from: json)
        #expect(AppDetailMapper.map(dto).fileSizeBytes == nil)
    }

    @Test("공백만 있는 releaseNotes 는 nil(섹션 숨김)")
    func blankReleaseNotesIsNil() throws {
        let json = Data(#"{"trackId": 1, "trackName": "A", "releaseNotes": "   \n "}"#.utf8)
        let dto = try JSONDecoder().decode(ITunesAppDTO.self, from: json)
        #expect(AppDetailMapper.map(dto).releaseNotes == nil)
    }

    private final class BundleToken {}
}
