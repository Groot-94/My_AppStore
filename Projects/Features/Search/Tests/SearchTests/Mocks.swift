//
//  Mocks.swift
//  SearchTests
//
//  Created by groot on 7/29/26.
//

import Foundation
import ITunesKit
@testable import Search

/// 결과/에러를 주입할 수 있는 `SearchRepository` 목.
actor MockSearchRepository: SearchRepository {
    enum Outcome: Sendable {
        case success([SearchResultItem])
        case failure
        /// 지정 시간(ns) 지연 후 성공 반환(취소 테스트용).
        case delayed([SearchResultItem], UInt64)
    }

    private var outcome: Outcome
    private(set) var receivedTerms: [String] = []
    private(set) var receivedLimits: [Int] = []

    /// 첫 요청이 `search()` 에 실제로 진입하면 이행되는 게이트(취소 테스트 결정화용).
    /// 테스트는 이 값을 await 한 뒤에야 두 번째 검색을 시작해, 스케줄링과 무관하게
    /// "첫 요청 진입 → 취소" 순서를 보장한다.
    private var entryContinuation: CheckedContinuation<Void, Never>?
    private var didEnter = false

    init(outcome: Outcome = .success([])) {
        self.outcome = outcome
    }

    func set(_ outcome: Outcome) {
        self.outcome = outcome
    }

    /// 첫 요청이 `search()` 에 진입할 때까지 대기한다.
    func waitForFirstEntry() async {
        if didEnter { return }
        await withCheckedContinuation { continuation in
            entryContinuation = continuation
        }
    }

    func search(term: String, limit: Int) async throws -> [SearchResultItem] {
        receivedTerms.append(term)
        receivedLimits.append(limit)
        didEnter = true
        entryContinuation?.resume()
        entryContinuation = nil

        switch outcome {
        case let .success(items):
            return items
        case .failure:
            throw MockError.network
        case let .delayed(items, delay):
            try await Task.sleep(nanoseconds: delay)
            try Task.checkCancellation()
            return items
        }
    }
}

/// 호출을 기록하는 `RecentSearching` 목.
actor MockRecentSearches: RecentSearching {
    private var _terms: [String]
    private(set) var addedTerms: [String] = []
    private(set) var clearCallCount = 0

    init(terms: [String] = []) {
        self._terms = terms
    }

    func recentTerms() -> [String] { _terms }

    func add(term: String) {
        addedTerms.append(term)
        _terms.removeAll { $0 == term }
        _terms.insert(term, at: 0)
    }

    func clear() {
        clearCallCount += 1
        _terms.removeAll()
    }
}

enum MockError: Error { case network }

/// search 응답을 주입하는 `ITunesClient` 목. 전달된 term/genreID/limit 을 기록.
actor MockITunesClient: ITunesClient {
    private let dtos: [ITunesAppDTO]
    private(set) var receivedTerm: String?
    private(set) var receivedGenreID: Int??
    private(set) var receivedLimit: Int?

    init(dtos: [ITunesAppDTO]) {
        self.dtos = dtos
    }

    func search(term: String, genreID: Int?, limit: Int) async throws -> [ITunesAppDTO] {
        receivedTerm = term
        receivedGenreID = genreID
        receivedLimit = limit
        return dtos
    }
    func lookup(ids: [Int]) async throws -> [ITunesAppDTO] { [] }
    func chart(_ feed: ChartFeed, limit: Int) async throws -> [RSSEntryDTO] { [] }
}

/// 테스트 픽스처 헬퍼.
enum TestSupport {
    static func item(id: Int, name: String = "App", price: String? = nil) -> SearchResultItem {
        SearchResultItem(
            id: id,
            name: name,
            sellerName: "Seller",
            genre: "Genre",
            iconURL: nil,
            rating: 4.0,
            ratingCount: 100,
            price: price
        )
    }
}
