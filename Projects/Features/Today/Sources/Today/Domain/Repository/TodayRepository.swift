//
//  TodayRepository.swift
//  Today
//
//  Created by groot on 7/29/26.
//

import Foundation

/// 정적 큐레이션 스토리 원본(JSON 원본: 메타 + 참조 appID 들).
public struct TodayStoryCuration: Sendable, Equatable, Identifiable {
    public let id: String
    public let kind: TodayCardKind
    public let eyebrow: String
    public let title: String
    public let subtitle: String
    public let appIDs: [Int]

    public init(
        id: String,
        kind: TodayCardKind,
        eyebrow: String,
        title: String,
        subtitle: String,
        appIDs: [Int]
    ) {
        self.id = id
        self.kind = kind
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.appIDs = appIDs
    }
}

/// Today 데이터 접근 계약(피처 Domain 소유, 프로토콜만).
public protocol TodayRepository: Sendable {
    /// 정적 큐레이션 스토리 목록.
    func curation() -> [TodayStoryCuration]
    /// 참조 appID 들을 lookup 으로 보강해 앱 요약으로 반환한다(순서는 요청 순서 유지).
    func summaries(ids: [Int]) async throws -> [TodayAppSummary]
}
