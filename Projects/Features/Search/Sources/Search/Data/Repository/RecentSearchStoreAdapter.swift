//
//  RecentSearchStoreAdapter.swift
//  Search
//
//  Created by groot on 7/29/26.
//

import Foundation
import Persistence

/// `Persistence.RecentSearchStore` 를 Domain 의 `RecentSearching` 로 잇는 어댑터.
public struct RecentSearchStoreAdapter: RecentSearching {
    private let store: RecentSearchStore

    public init(store: RecentSearchStore) {
        self.store = store
    }

    public func recentTerms() async -> [String] { await store.recentTerms() }
    public func add(term: String) async { await store.add(term: term) }
    public func clear() async { await store.clear() }
}
