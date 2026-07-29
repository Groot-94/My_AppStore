//
//  SearchAppsUseCase.swift
//  Search
//
//  Created by groot on 7/29/26.
//

import Foundation
import CoreKit

/// 앱 검색 UseCase 계약.
public protocol SearchAppsUseCase: Sendable {
    /// 검색어를 트림·검증한 뒤 검색을 수행하고, 성공 시 최근 검색어에 저장한다.
    /// - Parameter term: 원문 검색어(트림 전).
    /// - Returns: 검색 결과 엔티티 배열.
    /// - Throws: 빈/공백 검색어면 `CoreError.invalidInput`. 그 외 Repository 에러 전파.
    func execute(term: String) async throws -> [SearchResultItem]
}

/// 기본 구현. 트림/빈값 검증 후 Repository 호출, 저장은 `RecentSearching` 에 위임.
public struct DefaultSearchAppsUseCase: SearchAppsUseCase {
    private let repository: SearchRepository
    private let recentSearches: RecentSearching

    public init(repository: SearchRepository, recentSearches: RecentSearching) {
        self.repository = repository
        self.recentSearches = recentSearches
    }

    public func execute(term: String) async throws -> [SearchResultItem] {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw CoreError.invalidInput }

        // 결과 유무와 무관하게 검색 시점에 최근 검색어로 저장한다.
        recentSearches.add(term: trimmed)
        return try await repository.search(term: trimmed)
    }
}
