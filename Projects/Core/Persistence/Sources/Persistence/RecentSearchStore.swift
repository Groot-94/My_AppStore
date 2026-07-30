//
//  RecentSearchStore.swift
//  Persistence
//
//  Created by groot on 7/29/26.
//

import Foundation

/// 최근 검색어 저장소(Search 피처가 사용). 구현은 actor 로 직렬화한다.
public protocol RecentSearchStore: Sendable {
    /// 최신순 최근 검색어(최대 `maxCount`).
    func recentTerms() async -> [String]
    /// 검색어 추가. 중복이면 최상단으로 갱신, 최대 개수 초과분은 제거.
    func add(term: String) async
    /// 전체 비움.
    func clear() async
}

/// UserDefaults 기반 구현. 최대 10개·중복 시 최상단 갱신.
/// 읽기-수정-쓰기 원자성을 `actor` 격리로 보장한다(수동 락 불필요).
public actor DefaultRecentSearchStore: RecentSearchStore {
    private let defaults: UserDefaults
    private let key: String
    private let maxCount: Int

    /// - Parameters:
    ///   - defaults: 저장소(기본 `.standard`, 테스트는 전용 suite 주입).
    ///   - key: 저장 키.
    ///   - maxCount: 최대 보관 개수(기본 10).
    public init(
        defaults: UserDefaults = .standard,
        key: String = "recent_search_terms",
        maxCount: Int = 10
    ) {
        self.defaults = defaults
        self.key = key
        self.maxCount = maxCount
    }

    public func recentTerms() -> [String] {
        defaults.stringArray(forKey: key) ?? []
    }

    public func add(term: String) {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        var terms = defaults.stringArray(forKey: key) ?? []
        // 중복 제거(원문 유지) 후 최상단 삽입.
        terms.removeAll { $0 == trimmed }
        terms.insert(trimmed, at: 0)
        if terms.count > maxCount {
            terms = Array(terms.prefix(maxCount))
        }
        defaults.set(terms, forKey: key)
    }

    public func clear() {
        defaults.removeObject(forKey: key)
    }
}
