//
//  ArcadeFeed.swift
//  Arcade
//
//  Created by groot on 7/29/26.
//

import Foundation

/// 아케이드 게임 항목(Lookup 실데이터, Arcade 피처 소유 엔티티).
public struct ArcadeGame: Sendable, Equatable, Identifiable {
    public let id: Int
    public let name: String
    public let genre: String
    public let artworkURL: URL?

    public init(id: Int, name: String, genre: String, artworkURL: URL?) {
        self.id = id
        self.name = name
        self.genre = genre
        self.artworkURL = artworkURL
    }
}

/// 히어로 배너 정적 카피(큐레이션 소유).
public struct ArcadeHero: Sendable, Equatable {
    public let title: String
    public let subtitle: String

    public init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
}

/// Arcade 탭 피드 조립 결과.
public struct ArcadeFeed: Sendable, Equatable {
    public let hero: ArcadeHero
    public let newGames: [ArcadeGame]
    public let popular: [ArcadeGame]

    public init(hero: ArcadeHero, newGames: [ArcadeGame], popular: [ArcadeGame]) {
        self.hero = hero
        self.newGames = newGames
        self.popular = popular
    }

    /// 두 섹션이 모두 비었으면 빈 피드(안내 문구 표시).
    public var isEmpty: Bool {
        newGames.isEmpty && popular.isEmpty
    }
}
