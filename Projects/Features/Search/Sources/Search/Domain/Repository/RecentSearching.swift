//
//  RecentSearching.swift
//  Search
//
//  Created by groot on 7/29/26.
//

import Foundation

/// 최근 검색어 저장 추상화(피처 Domain 소유).
///
/// Domain 이 순수 Swift 를 유지하도록 Persistence 를 직접 참조하지 않는다.
public protocol RecentSearching: Sendable {
    /// 최신순 최근 검색어.
    func recentTerms() -> [String]
    /// 검색어 추가(중복 최상단 갱신, 최대 개수 유지는 구현이 담당).
    func add(term: String)
    /// 전체 비움.
    func clear()
}
