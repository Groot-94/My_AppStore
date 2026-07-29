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
/// `genreID` 필터는 RSS 장르 원본(DTO)이 필요해 Data 계층에서 수행하고 rank 를 재부여한다.
public protocol ChartRepository: Sendable {
    func chart(feed: ChartFeedKind, genreID: Int?, limit: Int) async throws -> [SeeAllItem]
}
