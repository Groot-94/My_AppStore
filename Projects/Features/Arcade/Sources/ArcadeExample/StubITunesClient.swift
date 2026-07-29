//
//  StubITunesClient.swift
//  ArcadeExample
//
//  Created by groot on 7/29/26.
//

import Foundation
import ITunesKit

/// 네트워크 없이 번들 픽스처 JSON 을 반환하는 Example 전용 스텁.
/// Core 를 오염시키지 않기 위해 Example 소스에 로컬 구현한다(`-useMocks` 모드에서만 사용).
struct StubITunesClient: ITunesClient {
    func search(term: String, genreID: Int?, limit: Int) async throws -> [ITunesAppDTO] {
        let response: ITunesSearchResponse = try Self.decode("search")
        return response.results
    }

    func lookup(ids: [Int]) async throws -> [ITunesAppDTO] {
        let response: ITunesSearchResponse = try Self.decode("lookup")
        return response.results
    }

    func chart(_ feed: ChartFeed, limit: Int) async throws -> [RSSEntryDTO] {
        let name = feed == .topPaid ? "rss-toppaid" : "rss-topfree"
        let response: RSSFeedResponse = try Self.decode(name)
        return response.feed.results
    }

    private static func decode<T: Decodable>(_ resource: String) throws -> T {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json") else {
            throw StubError.missingFixture(resource)
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }

    enum StubError: Error {
        case missingFixture(String)
    }
}
