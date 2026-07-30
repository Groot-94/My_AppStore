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
    private func makeStore(maxCount: Int = 10) -> DefaultRecentSearchStore {
        let suiteName = "recent.test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return DefaultRecentSearchStore(defaults: defaults, key: "terms", maxCount: maxCount)
    }

    @Test("추가 시 최신이 최상단")
    func addMostRecentFirst() async {
        let store = makeStore()
        await store.add(term: "a")
        await store.add(term: "b")
        #expect(await store.recentTerms() == ["b", "a"])
    }

    @Test("중복 추가 시 최상단으로 이동(중복 제거)")
    func dedupeToTop() async {
        let store = makeStore()
        await store.add(term: "a")
        await store.add(term: "b")
        await store.add(term: "a")
        #expect(await store.recentTerms() == ["a", "b"])
    }

    @Test("최대 개수 초과분 제거")
    func maxCount() async {
        let store = makeStore(maxCount: 3)
        for term in ["1", "2", "3", "4", "5"] { await store.add(term: term) }
        #expect(await store.recentTerms() == ["5", "4", "3"])
    }

    @Test("공백/빈 검색어는 무시")
    func ignoresBlank() async {
        let store = makeStore()
        await store.add(term: "   ")
        await store.add(term: "")
        #expect(await store.recentTerms().isEmpty)
    }

    @Test("검색어 트림 후 저장")
    func trims() async {
        let store = makeStore()
        await store.add(term: "  kakao  ")
        #expect(await store.recentTerms() == ["kakao"])
    }

    @Test("clear 후 비어 있음")
    func clear() async {
        let store = makeStore()
        await store.add(term: "a")
        await store.clear()
        #expect(await store.recentTerms().isEmpty)
    }
}
