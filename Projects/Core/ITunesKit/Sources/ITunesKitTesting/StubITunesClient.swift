//
//  StubITunesClient.swift
//  ITunesKitTesting
//
//  Created by groot on 7/31/26.
//

import Foundation
import ITunesKit

/// 네트워크 없이 번들 픽스처 JSON 을 반환하는 오프라인 스텁.
/// Example 앱이 실 네트워크 스택 없이 피처를 격리 실행할 때 주입한다.
public struct StubITunesClient: ITunesClient {
    public init() {}

    public func search(term: String, genreID: Int?, limit: Int) async throws -> [ITunesAppDTO] {
        let response: ITunesSearchResponse = try Self.decode("search")
        return response.results
    }

    public func lookup(ids: [Int]) async throws -> [ITunesAppDTO] {
        let response: ITunesSearchResponse = try Self.decode("lookup")
        return response.results
    }

    public func chart(_ feed: ChartFeed, limit: Int) async throws -> [RSSEntryDTO] {
        let name = feed == .topPaid ? "rss-toppaid" : "rss-topfree"
        let response: RSSFeedResponse = try Self.decode(name)
        return response.feed.results
    }

    private static func decode<T: Decodable>(_ resource: String) throws -> T {
        guard let url = Bundle.module.url(forResource: resource, withExtension: "json") else {
            throw StubError.missingFixture(resource)
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }

    enum StubError: Error {
        case missingFixture(String)
    }
}
