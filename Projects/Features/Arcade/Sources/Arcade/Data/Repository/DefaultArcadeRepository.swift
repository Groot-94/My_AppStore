//
//  DefaultArcadeRepository.swift
//  Arcade
//
//  Created by groot on 7/29/26.
//

import Foundation
import ITunesKit

/// `ArcadeRepository` 기본 구현. 번들 큐레이션 + Lookup 배치를 호출하고 DTO 를 엔티티로 매핑한다.
public struct DefaultArcadeRepository: ArcadeRepository {
    private let client: AppLookup
    private let bundle: Bundle

    public init(client: AppLookup, bundle: Bundle? = nil) {
        self.client = client
        self.bundle = bundle ?? .module
    }

    public func curation() -> ArcadeCuration? {
        ArcadeCurationDataSource.curation(bundle: bundle)
    }

    public func games(ids: [Int]) async throws -> [ArcadeGame] {
        guard !ids.isEmpty else { return [] }
        let dtos = try await client.lookup(ids: ids)
        return ArcadeMapper.games(dtos, ids: ids)
    }
}
