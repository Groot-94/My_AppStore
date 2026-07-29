//
//  URLSessionNetworkClient.swift
//  Networking
//
//  Created by groot on 7/29/26.
//

import Foundation
import CoreKit

/// `URLSession` 기반 `NetworkClient` 구현. 상태 검사(200..<300) + 전송 실패 재시도.
public struct URLSessionNetworkClient: NetworkClient {
    private let fetcher: HTTPDataFetching
    private let timeout: TimeInterval
    private let retryPolicy: RetryPolicy
    private let log = Log(category: "Networking")

    /// - Parameters:
    ///   - fetcher: URLSession 추상화(기본 `.shared`).
    ///   - timeout: 요청 타임아웃(초). 기본 15.
    ///   - retryPolicy: 전송 실패 재시도 정책. 기본 1회.
    public init(
        fetcher: HTTPDataFetching = URLSession.shared,
        timeout: TimeInterval = 15,
        retryPolicy: RetryPolicy = .single
    ) {
        self.fetcher = fetcher
        self.timeout = timeout
        self.retryPolicy = retryPolicy
    }

    public func data(for endpoint: Endpoint) async throws -> Data {
        let request = try endpoint.makeRequest(timeout: timeout)
        var attempt = 0

        while true {
            do {
                return try await performOnce(request)
            } catch let error as NetworkError {
                // 재시도는 전송 실패(URLError)에만 적용. 상태/디코딩 실패는 즉시 던짐.
                guard case .transport = error, attempt < retryPolicy.maxRetries else {
                    throw error
                }
                attempt += 1
                log.debug("재시도 \(attempt)/\(retryPolicy.maxRetries): \(request.url?.absoluteString ?? "")")
            }
        }
    }

    private func performOnce(_ request: URLRequest) async throws -> Data {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await fetcher.data(for: request)
        } catch let urlError as URLError {
            throw NetworkError.transport(urlError)
        } catch {
            throw NetworkError.transport(URLError(.unknown))
        }

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw NetworkError.unacceptableStatus(code: http.statusCode)
        }
        return data
    }
}
