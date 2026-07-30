//
//  LoadChartUseCase.swift
//  SeeAll
//
//  Created by groot on 7/29/26.
//

import Foundation
import SeeAllInterface

/// 차트 로드 UseCase 계약.
public protocol LoadChartUseCase: Sendable {
    /// 입력 feed 차트를 로드한다. `genreID` 가 있으면 장르 필터 후 rank 를 재부여한다.
    func execute(input: SeeAllInput) async throws -> [SeeAllItem]
}

/// 기본 구현. Repository 로 차트를 로드하고, `genreID` 가 있으면 게임 정책으로 필터·rank 재부여한다.
public struct DefaultLoadChartUseCase: LoadChartUseCase {
    private let repository: ChartRepository
    private let limit: Int

    public init(repository: ChartRepository, limit: Int = 50) {
        self.repository = repository
        self.limit = limit
    }

    public func execute(input: SeeAllInput) async throws -> [SeeAllItem] {
        let items = try await repository.chart(feed: input.feed, limit: limit)
        guard let genreID = input.genreID else { return items }
        return GameGenrePolicy.filtered(items, genreID: genreID)
    }
}
