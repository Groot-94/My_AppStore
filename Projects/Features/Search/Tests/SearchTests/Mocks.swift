//
//  Mocks.swift
//  SearchTests
//
//  Created by groot on 7/29/26.
//

import Foundation
@testable import Search

/// 결과/에러를 주입할 수 있는 `SearchRepository` 목.
final class MockSearchRepository: SearchRepository, @unchecked Sendable {
    enum Outcome: Sendable {
        case success([SearchResultItem])
        case failure
        /// 지정 시간(ns) 지연 후 성공 반환(취소 테스트용).
        case delayed([SearchResultItem], UInt64)
    }

    private let lock = NSLock()
    private var _outcome: Outcome
    private var _receivedTerms: [String] = []

    init(outcome: Outcome = .success([])) {
        self._outcome = outcome
    }

    func set(_ outcome: Outcome) {
        lock.lock(); defer { lock.unlock() }
        _outcome = outcome
    }

    var receivedTerms: [String] {
        lock.lock(); defer { lock.unlock() }
        return _receivedTerms
    }

    func search(term: String) async throws -> [SearchResultItem] {
        let outcome: Outcome = lock.withLock {
            _receivedTerms.append(term)
            return _outcome
        }
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
final class MockRecentSearches: RecentSearching, @unchecked Sendable {
    private let lock = NSLock()
    private var _terms: [String]
    private(set) var addedTerms: [String] = []
    private(set) var clearCallCount = 0

    init(terms: [String] = []) {
        self._terms = terms
    }

    func recentTerms() -> [String] {
        lock.withLock { _terms }
    }

    func add(term: String) {
        lock.withLock {
            addedTerms.append(term)
            _terms.removeAll { $0 == term }
            _terms.insert(term, at: 0)
        }
    }

    func clear() {
        lock.withLock {
            clearCallCount += 1
            _terms.removeAll()
        }
    }
}

enum MockError: Error { case network }

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
