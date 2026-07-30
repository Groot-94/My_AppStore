//
//  AppDetailPresentationTests.swift
//  AppDetailTests
//
//  Created by groot on 7/30/26.
//

import Testing
import Foundation
@testable import AppDetail

@Suite("AppDetailPresentation")
struct AppDetailPresentationTests {

    private func detail(
        version: String = "1.0",
        updatedAt: Date? = nil,
        rating: Double = 0,
        ratingCount: Int = 0,
        price: String? = nil,
        genre: String = "",
        contentRating: String = "",
        sellerName: String = "",
        fileSizeBytes: Int64? = nil,
        minimumOSVersion: String = "",
        languages: [String] = [],
        screenshotURLs: [URL] = [],
        description: String = "",
        releaseNotes: String? = nil
    ) -> AppDetail {
        AppDetail(
            id: 1, name: "App", sellerName: sellerName, genre: genre,
            iconURL: nil, screenshotURLs: screenshotURLs, description: description,
            releaseNotes: releaseNotes, version: version, updatedAt: updatedAt,
            rating: rating, ratingCount: ratingCount, price: price,
            contentRating: contentRating, fileSizeBytes: fileSizeBytes,
            minimumOSVersion: minimumOSVersion, languages: languages
        )
    }

    // MARK: - abbreviate (1천/1만 경계)

    @Test("abbreviate: 1000 미만은 그대로")
    func abbreviateBelowThousand() {
        #expect(AppDetailPresentation.abbreviate(999) == "999")
    }

    @Test("abbreviate: 1000 경계는 천 단위")
    func abbreviateThousandBoundary() {
        #expect(AppDetailPresentation.abbreviate(1_000) == "1.0천")
        #expect(AppDetailPresentation.abbreviate(9_999) == "10.0천")
    }

    @Test("abbreviate: 10000 경계는 만 단위")
    func abbreviateTenThousandBoundary() {
        #expect(AppDetailPresentation.abbreviate(10_000) == "1.0만")
        #expect(AppDetailPresentation.abbreviate(844_631) == "84.5만")
    }

    // MARK: - fileSize (MB/GB 경계)

    @Test("fileSize: 1024MB 미만은 MB")
    func fileSizeMB() {
        let bytes = Int64(500 * 1024 * 1024)
        #expect(AppDetailPresentation.fileSize(bytes) == "500.0MB")
    }

    @Test("fileSize: 1024MB 이상은 GB")
    func fileSizeGBBoundary() {
        let bytes = Int64(1024 * 1024 * 1024)
        #expect(AppDetailPresentation.fileSize(bytes) == "1.0GB")
    }

    // MARK: - versionLine 4조합

    @Test("versionLine: 버전+갱신일 모두 있음")
    func versionAndDate() {
        let now = Date(timeIntervalSince1970: 1_000_000)
        let updated = Date(timeIntervalSince1970: 1_000_000 - 86_400)
        let model = AppDetailPresentation(detail: detail(version: "2.1", updatedAt: updated), now: now)
        #expect(model.versionLine.hasPrefix("버전 2.1 · "))
    }

    @Test("versionLine: 버전만 있음(갱신일 nil)")
    func versionOnly() {
        let model = AppDetailPresentation(detail: detail(version: "2.1", updatedAt: nil))
        #expect(model.versionLine == "버전 2.1")
    }

    @Test("versionLine: 갱신일만 있음(버전 빈 문자열)")
    func dateOnly() {
        let now = Date(timeIntervalSince1970: 1_000_000)
        let updated = Date(timeIntervalSince1970: 1_000_000 - 86_400)
        let model = AppDetailPresentation(detail: detail(version: "", updatedAt: updated), now: now)
        #expect(model.versionLine.isEmpty == false)
        #expect(model.versionLine.contains("버전") == false)
    }

    @Test("versionLine: 둘 다 없음(빈 문자열)")
    func neither() {
        let model = AppDetailPresentation(detail: detail(version: "", updatedAt: nil))
        #expect(model.versionLine.isEmpty)
    }

    // MARK: - 조건부 노출

    @Test("평점 0 이면 평점 메타 셀 제외")
    func hidesRatingCellWhenZero() {
        let model = AppDetailPresentation(detail: detail(rating: 0, ratingCount: 100))
        #expect(model.metaCells.contains { $0.value == "0.0" } == false)
    }

    @Test("평점 있으면 ratingCount 유무로 caption 분기")
    func ratingCaptionDependsOnCount() {
        let withCount = AppDetailPresentation(detail: detail(rating: 4.5, ratingCount: 12_345))
        #expect(withCount.metaCells.first?.caption == "1.2만개의 평가")

        let noCount = AppDetailPresentation(detail: detail(rating: 4.5, ratingCount: 0))
        #expect(noCount.metaCells.first?.caption == "평가")
    }

    @Test("빈 필드는 info 행에서 제외")
    func hidesEmptyInfoRows() {
        let model = AppDetailPresentation(detail: detail())
        #expect(model.infoRows.isEmpty)
    }

    @Test("크기/호환성/언어/연령 채워지면 info 행 노출")
    func showsPopulatedInfoRows() {
        let model = AppDetailPresentation(detail: detail(
            genre: "게임",
            contentRating: "4+",
            fileSizeBytes: 1024 * 1024,
            minimumOSVersion: "17.0",
            languages: ["KO", "EN"]
        ))
        #expect(model.infoRows.contains { $0.title == "크기" })
        #expect(model.infoRows.contains { $0.title == "호환성" && $0.value == "iOS 17.0+" })
        #expect(model.infoRows.contains { $0.title == "언어" && $0.value == "KO 외 1개" })
    }

    // MARK: - priceText 폴백

    @Test("price nil 이면 '무료' 폴백")
    func priceFallback() {
        #expect(AppDetailPresentation(detail: detail(price: nil)).priceText == "무료")
    }

    @Test("price 있으면 그대로 표시")
    func priceRaw() {
        #expect(AppDetailPresentation(detail: detail(price: "₩1,100")).priceText == "₩1,100")
    }
}
