//
//  RecentSearchStoreTests.swift
//  PersistenceTests
//
//  Created by groot on 7/29/26.
//

import Testing
import Foundation
@testable import Persistence

@Suite("DefaultRecentSearchStore")
struct RecentSearchStoreTests {

    /// 테스트 격리를 위해 매번 고유 suite 사용.
    private func makeStore(maxCount: Int = 10) -> (DefaultRecentSearchStore, UserDefaults) {
        let suiteName = "recent.test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let store = DefaultRecentSearchStore(defaults: defaults, key: "terms", maxCount: maxCount)
        return (store, defaults)
    }

    @Test("추가 시 최신이 최상단")
    func addMostRecentFirst() {
        let (store, _) = makeStore()
        store.add(term: "a")
        store.add(term: "b")
        #expect(store.recentTerms() == ["b", "a"])
    }

    @Test("중복 추가 시 최상단으로 이동(중복 제거)")
    func dedupeToTop() {
        let (store, _) = makeStore()
        store.add(term: "a")
        store.add(term: "b")
        store.add(term: "a")
        #expect(store.recentTerms() == ["a", "b"])
    }

    @Test("최대 개수 초과분 제거")
    func maxCount() {
        let (store, _) = makeStore(maxCount: 3)
        for term in ["1", "2", "3", "4", "5"] { store.add(term: term) }
        #expect(store.recentTerms() == ["5", "4", "3"])
    }

    @Test("공백/빈 검색어는 무시")
    func ignoresBlank() {
        let (store, _) = makeStore()
        store.add(term: "   ")
        store.add(term: "")
        #expect(store.recentTerms().isEmpty)
    }

    @Test("검색어 트림 후 저장")
    func trims() {
        let (store, _) = makeStore()
        store.add(term: "  kakao  ")
        #expect(store.recentTerms() == ["kakao"])
    }

    @Test("clear 후 비어 있음")
    func clear() {
        let (store, _) = makeStore()
        store.add(term: "a")
        store.clear()
        #expect(store.recentTerms().isEmpty)
    }
}
