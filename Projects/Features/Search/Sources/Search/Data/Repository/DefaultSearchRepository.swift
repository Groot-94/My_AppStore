//
//  DefaultSearchRepository.swift
//  Search
//
//  Created by groot on 7/29/26.
//

import Foundation
import ITunesKit

/// `SearchRepository` 기본 구현. `ITunesClient.search` 호출 후 DTO → 엔티티 매핑.
public struct DefaultSearchRepository: SearchRepository {
    /// 검색 결과 최대 개수.
    static let searchLimit = 25

    private let client: ITunesClient

    public init(client: ITunesClient) {
        self.client = client
    }

    public func search(term: String) async throws -> [SearchResultItem] {
        let dtos = try await client.search(term: term, genreID: nil, limit: Self.searchLimit)
        return SearchResultItemMapper.map(dtos)
    }
}
