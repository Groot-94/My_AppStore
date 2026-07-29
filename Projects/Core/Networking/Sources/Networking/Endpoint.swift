//
//  Endpoint.swift
//  Networking
//
//  Created by groot on 7/29/26.
//

import Foundation

/// HTTP 메서드(현재 GET 만 사용 — iTunes 는 조회 전용).
public enum HTTPMethod: String, Sendable {
    case get = "GET"
}

/// 범용 요청 서술자(요청 빌더). 스킴/호스트/경로/쿼리만 안다.
public struct Endpoint: Sendable, Equatable {
    public let scheme: String
    public let host: String
    public let path: String
    public let queryItems: [URLQueryItem]
    public let method: HTTPMethod

    public init(
        scheme: String = "https",
        host: String,
        path: String,
        queryItems: [URLQueryItem] = [],
        method: HTTPMethod = .get
    ) {
        self.scheme = scheme
        self.host = host
        self.path = path
        self.queryItems = queryItems
        self.method = method
    }

    /// 완성된 `URL`. 구성 실패 시 `nil`.
    public var url: URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        return components.url
    }

    /// `URLRequest` 로 변환. URL 구성 실패 시 `NetworkError.invalidURL`.
    public func makeRequest(timeout: TimeInterval) throws -> URLRequest {
        guard let url else { throw NetworkError.invalidURL }
        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.httpMethod = method.rawValue
        return request
    }
}
