//
//  AppDetailRepository.swift
//  AppDetail
//
//  Created by groot on 7/29/26.
//

import Foundation

/// 앱 상세 데이터 접근 계약(피처 Domain 소유, 프로토콜만).
///
/// Domain 은 순수 Swift — ITunesKit/Persistence 를 모른다.
public protocol AppDetailRepository: Sendable {
    /// appID 로 상세를 조회한다.
    /// - Throws: 결과 0건이면 `CoreError.notFound`. 그 외 하부 에러 전파.
    func fetch(appID: Int) async throws -> AppDetail
}
