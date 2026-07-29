//
//  EndpointTests.swift
//  NetworkingTests
//
//  Created by groot on 7/29/26.
//

import Testing
import Foundation
@testable import Networking

@Suite("Endpoint 요청 빌더")
struct EndpointTests {
    @Test("URL 구성: 스킴/호스트/경로/쿼리 반영")
    func buildsURL() throws {
        let endpoint = Endpoint(
            host: "example.com",
            path: "/search",
            queryItems: [
                URLQueryItem(name: "term", value: "kakao"),
                URLQueryItem(name: "limit", value: "25"),
            ]
        )
        let url = try #require(endpoint.url)
        #expect(url.scheme == "https")
        #expect(url.host == "example.com")
        #expect(url.path == "/search")
        let query = try #require(url.query)
        #expect(query.contains("term=kakao"))
        #expect(query.contains("limit=25"))
    }

    @Test("쿼리 없으면 queryItems 미포함")
    func noQuery() throws {
        let endpoint = Endpoint(host: "example.com", path: "/apps.json")
        let url = try #require(endpoint.url)
        #expect(url.query == nil)
    }

    @Test("URLRequest: 메서드/타임아웃 반영")
    func makesRequest() throws {
        let endpoint = Endpoint(host: "example.com", path: "/x")
        let request = try endpoint.makeRequest(timeout: 7)
        #expect(request.httpMethod == "GET")
        #expect(request.timeoutInterval == 7)
    }
}
