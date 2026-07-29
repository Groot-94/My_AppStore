//
//  LoadArcadeFeedUseCase.swift
//  Arcade
//
//  Created by groot on 7/29/26.
//

import Foundation
import CoreKit

/// Arcade 피드 로드 UseCase 계약.
public protocol LoadArcadeFeedUseCase: Sendable {
    /// 정적 큐레이션 + 참조 게임 lookup 배치를 조립해 피드로 반환한다.
    /// 빈 큐레이션은 빈 피드(안내 문구)로 표현하며, 큐레이션 자체가 없을 때만 `CoreError.notFound`.
    func execute() async throws -> ArcadeFeed
}

/// 기본 구현. 두 섹션의 참조 ID 를 한 번의 lookup 배치로 채우고, 실패 항목은 제외한다(부분 실패 허용).
public struct DefaultLoadArcadeFeedUseCase: LoadArcadeFeedUseCase {
    private let repository: ArcadeRepository

    public init(repository: ArcadeRepository) {
        self.repository = repository
    }

    public func execute() async throws -> ArcadeFeed {
        guard let curation = repository.curation() else { throw CoreError.notFound }

        let allIDs = Array(Set(curation.newGameIDs + curation.popularIDs))
        // 빈 큐레이션(참조 게임 없음)은 히어로만 있는 빈 피드로 반환.
        guard !allIDs.isEmpty else {
            return ArcadeFeed(hero: curation.hero, newGames: [], popular: [])
        }

        let games = try await repository.games(ids: allIDs)
        let byID = Dictionary(games.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

        return ArcadeFeed(
            hero: curation.hero,
            newGames: curation.newGameIDs.compactMap { byID[$0] },
            popular: curation.popularIDs.compactMap { byID[$0] }
        )
    }
}
