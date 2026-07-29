import Foundation
import Persistence

/// `Persistence.RecentSearchStore` 를 Domain 의 `RecentSearching` 로 잇는 어댑터.
///
/// Domain 이 Persistence 를 몰라도 되도록 Data 계층에서 연결한다(docs/02 경계).
public struct RecentSearchStoreAdapter: RecentSearching {
    private let store: RecentSearchStore

    public init(store: RecentSearchStore) {
        self.store = store
    }

    public func recentTerms() -> [String] { store.recentTerms() }
    public func add(term: String) { store.add(term: term) }
    public func clear() { store.clear() }
}
