//
//  TodayCard.swift
//  Today
//
//  Created by groot on 7/29/26.
//

import Foundation

/// 카드에 참조된 개별 앱의 실데이터(Lookup 으로 채움).
public struct TodayAppSummary: Sendable, Equatable, Identifiable {
    public let id: Int
    public let name: String
    public let genre: String
    public let iconURL: URL?
    public let priceText: String

    public init(id: Int, name: String, genre: String, iconURL: URL?, priceText: String) {
        self.id = id
        self.name = name
        self.genre = genre
        self.iconURL = iconURL
        self.priceText = priceText
    }
}

/// Today 카드 유형(에디터 큐레이션 레이아웃 구분).
public enum TodayCardKind: String, Sendable, Equatable {
    /// 대형 피처 카드(대표 앱 1개 강조).
    case feature
    /// 앱·게임 오브 더 데이(대표 앱 1개, 강조 배지).
    case appOfTheDay
    /// 리스트형 카드(추천 앱 여러 개).
    case list
}

/// Today 피드 카드(정적 큐레이션 메타 + 참조 앱 실데이터 조립 결과).
public struct TodayCard: Sendable, Equatable, Identifiable {
    public let id: String
    public let kind: TodayCardKind
    public let eyebrow: String
    public let title: String
    public let subtitle: String
    public let apps: [TodayAppSummary]

    public init(
        id: String,
        kind: TodayCardKind,
        eyebrow: String,
        title: String,
        subtitle: String,
        apps: [TodayAppSummary]
    ) {
        self.id = id
        self.kind = kind
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.apps = apps
    }

    /// 카드 탭 시 이동할 대표 앱(첫 참조 앱).
    public var primaryApp: TodayAppSummary? { apps.first }
}
