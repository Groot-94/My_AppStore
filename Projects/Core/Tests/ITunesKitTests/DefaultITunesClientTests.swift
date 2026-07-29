import Testing
import Foundation
import CoreKit
import Networking
@testable import ITunesKit

@Suite("DefaultITunesClient 동작(NetworkClient 목)")
struct DefaultITunesClientTests {

    private func makeClient() throws -> (DefaultITunesClient, MockNetworkClient) {
        let mock = MockNetworkClient()
        mock.setResponse(try FixtureLoader.data("search"), forPathContaining: "/search")
        mock.setResponse(try FixtureLoader.data("lookup"), forPathContaining: "/lookup")
        mock.setResponse(try FixtureLoader.data("rss-topfree"), forPathContaining: "apps.json")
        let client = DefaultITunesClient(network: mock, config: .korea)
        return (client, mock)
    }

    @Test("search: DTO 반환 + 요청 쿼리에 country/lang/entity 반영")
    func search() async throws {
        let (client, mock) = try makeClient()
        let results = try await client.search(term: "kakao", genreID: nil, limit: 25)
        #expect(!results.isEmpty)

        let endpoint = try #require(mock.requestedEndpoints.first)
        let query = endpoint.queryItems
        #expect(query.contains(URLQueryItem(name: "country", value: "kr")))
        #expect(query.contains(URLQueryItem(name: "lang", value: "ko_kr")))
        #expect(query.contains(URLQueryItem(name: "entity", value: "software")))
        #expect(query.contains(URLQueryItem(name: "term", value: "kakao")))
        #expect(query.contains(URLQueryItem(name: "limit", value: "25")))
    }

    @Test("search: genreID 있으면 쿼리에 포함")
    func searchWithGenre() async throws {
        let (client, mock) = try makeClient()
        _ = try await client.search(term: "puzzle", genreID: 6014, limit: 10)
        let endpoint = try #require(mock.requestedEndpoints.first)
        #expect(endpoint.queryItems.contains(URLQueryItem(name: "genreId", value: "6014")))
    }

    @Test("lookup: 빈 ids 는 네트워크 호출 없이 빈 배열")
    func lookupEmpty() async throws {
        let (client, mock) = try makeClient()
        let results = try await client.lookup(ids: [])
        #expect(results.isEmpty)
        #expect(mock.requestedEndpoints.isEmpty)
    }

    @Test("lookup: id 콤마 조인")
    func lookupJoinsIDs() async throws {
        let (client, mock) = try makeClient()
        _ = try await client.lookup(ids: [1, 2, 3])
        let endpoint = try #require(mock.requestedEndpoints.first)
        #expect(endpoint.queryItems.contains(URLQueryItem(name: "id", value: "1,2,3")))
    }

    @Test("chart: RSS 중첩 구조에서 results 추출 + 경로에 country/feed/limit")
    func chart() async throws {
        let (client, mock) = try makeClient()
        let entries = try await client.chart(.topFree, limit: 10)
        #expect(!entries.isEmpty)
        let endpoint = try #require(mock.requestedEndpoints.first)
        #expect(endpoint.path == "/api/v2/kr/apps/top-free/10/apps.json")
    }

    @Test("네트워크 에러 전파")
    func errorPropagates() async throws {
        let mock = MockNetworkClient()
        mock.setError(.unacceptableStatus(code: 500))
        let client = DefaultITunesClient(network: mock, config: .korea)
        await #expect(throws: NetworkError.unacceptableStatus(code: 500)) {
            _ = try await client.search(term: "x", genreID: nil, limit: 1)
        }
    }
}
