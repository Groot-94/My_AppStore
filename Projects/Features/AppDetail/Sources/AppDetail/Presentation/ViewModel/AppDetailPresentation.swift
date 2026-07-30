//
//  AppDetailPresentation.swift
//  AppDetail
//
//  Created by groot on 7/29/26.
//

import Foundation
import DesignSystem

/// `AppDetail` 엔티티를 화면 표시 문자열로 변환한 뷰용 구성 모델.
///
/// DesignSystem/뷰가 엔티티를 모르도록, 포매팅은 여기서 끝낸다.
public struct AppDetailPresentation: Equatable, Sendable {
    public struct MetaCell: Equatable, Sendable { public let caption: String; public let value: String }
    public struct InfoRow: Equatable, Sendable { public let title: String; public let value: String }

    public let name: String
    public let sellerName: String
    public let iconURL: URL?
    public let priceText: String
    public let screenshotURLs: [URL]
    public let description: String
    public let releaseNotes: String?
    public let metaCells: [MetaCell]
    public let versionLine: String
    public let infoRows: [InfoRow]

    /// - Parameter now: 상대 날짜 기준 시각. 주입으로 결정적 테스트를 가능케 한다.
    public init(detail: AppDetail, now: Date = Date()) {
        name = detail.name
        sellerName = detail.sellerName
        iconURL = detail.iconURL
        priceText = detail.price ?? CommonStrings.Price.free
        screenshotURLs = detail.screenshotURLs
        description = detail.description
        releaseNotes = detail.releaseNotes
        metaCells = Self.makeMetaCells(detail)
        versionLine = Self.makeVersionLine(detail, now: now)
        infoRows = Self.makeInfoRows(detail)
    }

    private static func makeMetaCells(_ detail: AppDetail) -> [MetaCell] {
        var cells: [MetaCell] = []
        if detail.rating > 0 {
            cells.append(MetaCell(
                caption: detail.ratingCount > 0 ? "\(abbreviate(detail.ratingCount))개의 평가" : "평가",
                value: String(format: "%.1f", detail.rating)
            ))
        }
        if !detail.contentRating.isEmpty {
            cells.append(MetaCell(caption: "연령", value: detail.contentRating))
        }
        if !detail.genre.isEmpty {
            cells.append(MetaCell(caption: "카테고리", value: detail.genre))
        }
        if !detail.sellerName.isEmpty {
            cells.append(MetaCell(caption: "개발자", value: detail.sellerName))
        }
        if let language = detail.languages.first {
            let value = detail.languages.count > 1 ? "\(language) 외 \(detail.languages.count - 1)" : language
            cells.append(MetaCell(caption: "언어", value: value))
        }
        return cells
    }

    private static func makeVersionLine(_ detail: AppDetail, now: Date) -> String {
        let version = detail.version.isEmpty ? "" : "버전 \(detail.version)"
        guard let updatedAt = detail.updatedAt else { return version }
        let relative = relativeDate(updatedAt, now: now)
        return version.isEmpty ? relative : "\(version) · \(relative)"
    }

    private static func makeInfoRows(_ detail: AppDetail) -> [InfoRow] {
        var rows: [InfoRow] = []
        if let size = detail.fileSizeBytes {
            rows.append(InfoRow(title: "크기", value: fileSize(size)))
        }
        if !detail.genre.isEmpty {
            rows.append(InfoRow(title: "카테고리", value: detail.genre))
        }
        if !detail.minimumOSVersion.isEmpty {
            rows.append(InfoRow(title: "호환성", value: "iOS \(detail.minimumOSVersion)+"))
        }
        if let language = detail.languages.first {
            let value = detail.languages.count > 1 ? "\(language) 외 \(detail.languages.count - 1)개" : language
            rows.append(InfoRow(title: "언어", value: value))
        }
        if !detail.contentRating.isEmpty {
            rows.append(InfoRow(title: "연령 등급", value: detail.contentRating))
        }
        return rows
    }

    // MARK: - Formatting

    static func fileSize(_ bytes: Int64) -> String {
        let mb = Double(bytes) / (1024 * 1024)
        if mb >= 1024 {
            return String(format: "%.1fGB", mb / 1024)
        }
        return String(format: "%.1fMB", mb)
    }

    static func abbreviate(_ count: Int) -> String {
        switch count {
        case 10_000...:
            return String(format: "%.1f만", Double(count) / 10_000)
        case 1_000...:
            return String(format: "%.1f천", Double(count) / 1_000)
        default:
            return "\(count)"
        }
    }

    private static func relativeDate(_ date: Date, now: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: now)
    }
}
