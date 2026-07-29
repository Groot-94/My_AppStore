import Foundation
import CoreKit
import Networking

/// iTunes 차트 피드 종류(docs/04-data-api.md).
public enum ChartFeed: String, Sendable {
    case topFree = "top-free"
    case topPaid = "top-paid"
}

/// iTunes API 3종(Search/Lookup/RSS) 호출 계약.
///
/// 시그니처는 docs/04-data-api.md 를 따른다. 구현(`DefaultITunesClient`)은 M1 범위.
public protocol ITunesClient: Sendable {
    func search(term: String, genreID: Int?, limit: Int) async throws -> [ITunesAppDTO]
    func lookup(ids: [Int]) async throws -> [ITunesAppDTO]
    func chart(_ feed: ChartFeed, limit: Int) async throws -> [RSSEntryDTO]
}
