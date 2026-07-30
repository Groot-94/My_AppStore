//
//  ChartRepository.swift
//  SeeAll
//
//  Created by groot on 7/29/26.
//

import Foundation
import SeeAllInterface

/// 차트 데이터 접근 계약(피처 Domain 소유, 프로토콜만).
///
/// Domain 은 순수 Swift — ITunesKit 를 모른다. 피드 종류는 Interface 소유 타입으로 표현.
/// 장르 정보를 담은 항목 전체를 반환하며, 게임 필터·rank 재부여는 UseCase(Domain 정책)가 수행한다.
public protocol ChartRepository: Sendable {
    func chart(feed: ChartFeedKind, limit: Int) async throws -> [SeeAllItem]
}
