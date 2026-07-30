//
//  SearchRepository.swift
//  Search
//
//  Created by groot on 7/29/26.
//

import Foundation

/// 검색 데이터 접근 계약(피처 Domain 소유, 프로토콜만).
///
/// Domain 은 순수 Swift — ITunesKit/Networking 을 모른다.
public protocol SearchRepository: Sendable {
    /// 검색어로 앱을 조회해 엔티티 배열을 반환한다.
    /// - Parameters:
    ///   - term: 트림된 유효 검색어.
    ///   - limit: 조회 최대 개수(정책은 UseCase 가 주입).
    func search(term: String, limit: Int) async throws -> [SearchResultItem]
}
