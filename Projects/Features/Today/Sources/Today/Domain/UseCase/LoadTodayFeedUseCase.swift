//
//  LoadTodayFeedUseCase.swift
//  Today
//
//  Created by groot on 7/29/26.
//

import Foundation
import CoreKit

/// Today 피드 로드 UseCase 계약.
public protocol LoadTodayFeedUseCase: Sendable {
    /// 정적 큐레이션 + 참조 앱 lookup 배치를 조립해 카드 배열로 반환한다.
    /// - Throws: 큐레이션이 비었거나 조립된 카드가 하나도 없을 때 `CoreError.notFound`.
    func execute() async throws -> [TodayCard]
}

/// 기본 구현. 전 스토리의 참조 ID 를 한 번의 lookup 배치로 채우고,
/// 참조 앱이 전부 실패한 카드는 카드째 제외한다(부분 실패 허용).
public struct DefaultLoadTodayFeedUseCase: LoadTodayFeedUseCase {
    private let repository: TodayRepository

    public init(repository: TodayRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [TodayCard] {
        let stories = repository.curation()
        guard !stories.isEmpty else { throw CoreError.notFound }

        let allIDs = Array(Set(stories.flatMap(\.appIDs)))
        let summaries = try await repository.summaries(ids: allIDs)
        let byID = Dictionary(summaries.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

        let cards: [TodayCard] = stories.compactMap { story in
            let apps = story.appIDs.compactMap { byID[$0] }
            guard !apps.isEmpty else { return nil }
            return TodayCard(
                id: story.id,
                kind: story.kind,
                eyebrow: story.eyebrow,
                title: story.title,
                subtitle: story.subtitle,
                apps: apps
            )
        }

        guard !cards.isEmpty else { throw CoreError.notFound }
        return cards
    }
}
