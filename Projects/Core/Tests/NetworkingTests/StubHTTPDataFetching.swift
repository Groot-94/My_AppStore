//
//  StubHTTPDataFetching.swift
//  NetworkingTests
//
//  Created by groot on 7/29/26.
//

import Foundation
@testable import Networking

/// 테스트용 `HTTPDataFetching` 스텁. 응답/에러를 미리 지정하고 호출 횟수를 센다.
actor StubHTTPDataFetching: HTTPDataFetching {
    enum Outcome {
        case success(Data, statusCode: Int)
        case failure(URLError)
    }

    private var outcomes: [Outcome]
    private(set) var callCount = 0

    /// - Parameter outcomes: 호출 순서대로 소비할 결과들. 다 쓰면 마지막을 반복.
    init(outcomes: [Outcome]) {
        self.outcomes = outcomes
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        callCount += 1
        let outcome = outcomes.count >= callCount ? outcomes[callCount - 1] : outcomes[outcomes.count - 1]
        switch outcome {
        case let .success(data, statusCode):
            let response = HTTPURLResponse(
                url: request.url ?? URL(string: "https://example.com")!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            return (data, response)
        case let .failure(error):
            throw error
        }
    }

    func recordedCallCount() -> Int { callCount }
}
