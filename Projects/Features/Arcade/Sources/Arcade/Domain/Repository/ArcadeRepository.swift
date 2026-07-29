//
//  ArcadeRepository.swift
//  Arcade
//
//  Created by groot on 7/29/26.
//

import Foundation

/// 정적 아케이드 큐레이션 원본(히어로 카피 + 섹션별 appID 목록).
public struct ArcadeCuration: Sendable, Equatable {
    public let hero: ArcadeHero
    public let newGameIDs: [Int]
    public let popularIDs: [Int]

    public init(hero: ArcadeHero, newGameIDs: [Int], popularIDs: [Int]) {
        self.hero = hero
        self.newGameIDs = newGameIDs
        self.popularIDs = popularIDs
    }
}

/// Arcade 데이터 접근 계약(피처 Domain 소유, 프로토콜만).
public protocol ArcadeRepository: Sendable {
    /// 정적 큐레이션(히어로 카피 + 섹션 appID). 파싱 실패 시 nil.
    func curation() -> ArcadeCuration?
    /// 참조 appID 들을 lookup 으로 보강해 게임으로 반환한다(순서는 요청 순서 유지).
    func games(ids: [Int]) async throws -> [ArcadeGame]
}
