//
//  Mocks.swift
//  TodayTests
//
//  Created by groot on 7/29/26.
//

import Foundation
import Testing
import ITunesKit
@testable import Today

/// 큐레이션/요약 결과를 주입할 수 있는 `TodayRepository` 목.
actor MockTodayRepository: TodayRepository {
    enum Outcome: Sendable {
        case success([TodayAppSummary])
        case failure
    }

    private let staticCuration: [TodayStoryCuration]
    private var outcomes: [Outcome]
    private(set) var requestedIDs: [Int] = []

    /// 호출마다 앞에서부터 소비하는 결과 큐. 큐가 비면 마지막 결과를 반복한다.
    init(curation: [TodayStoryCuration], summaries: Outcome = .success([])) {
        self.staticCuration = curation
        self.outcomes = [summaries]
    }

    init(curation: [TodayStoryCuration], summariesQueue: [Outcome]) {
        self.staticCuration = curation
        self.outcomes = summariesQueue
    }

    nonisolated func curation() -> [TodayStoryCuration] { staticCuration }

    func summaries(ids: [Int]) async throws -> [TodayAppSummary] {
        requestedIDs.append(contentsOf: ids)
        let outcome: Outcome = outcomes.count > 1 ? outcomes.removeFirst() : (outcomes.first ?? .success([]))
        switch outcome {
        case let .success(all):
            return all.filter { ids.contains($0.id) }
        case .failure:
            throw MockError.network
        }
    }
}

/// lookup 응답을 주입하는 `ITunesClient` 목.
actor MockITunesClient: ITunesClient {
    private let lookupResult: [ITunesAppDTO]
    private(set) var lookupIDs: [Int] = []

    init(lookupResult: [ITunesAppDTO] = []) {
        self.lookupResult = lookupResult
    }

    func search(term: String, genreID: Int?, limit: Int) async throws -> [ITunesAppDTO] { [] }

    func lookup(ids: [Int]) async throws -> [ITunesAppDTO] {
        lookupIDs.append(contentsOf: ids)
        return lookupResult
    }

    func chart(_ feed: ChartFeed, limit: Int) async throws -> [RSSEntryDTO] { [] }
}

enum MockError: Error { case network }

enum TestSupport {
    static func summary(id: Int) -> TodayAppSummary {
        TodayAppSummary(id: id, name: "App \(id)", genre: "Games", iconURL: nil, priceText: "받기")
    }

    static func story(id: String, kind: TodayCardKind = .list, appIDs: [Int]) -> TodayStoryCuration {
        TodayStoryCuration(id: id, kind: kind, eyebrow: "eb", title: "t", subtitle: "s", appIDs: appIDs)
    }

    static func lookupDTOs(named name: String) throws -> [ITunesAppDTO] {
        let bundle = Bundle(for: BundleToken.self)
        let url = try #require(bundle.url(forResource: name, withExtension: "json"))
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(ITunesSearchResponse.self, from: data).results
    }

    private final class BundleToken {}
}
