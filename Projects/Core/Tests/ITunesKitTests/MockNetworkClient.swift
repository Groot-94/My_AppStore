import Foundation
import os
import Networking

/// 테스트용 `NetworkClient` 목. 엔드포인트 경로별로 픽스처 데이터를 반환한다.
///
/// 요청된 엔드포인트를 기록해 DefaultITunesClient 의 요청 구성을 검증한다.
/// async 컨텍스트에서 안전하도록 `OSAllocatedUnfairLock` 으로 상태를 보호한다.
final class MockNetworkClient: NetworkClient, @unchecked Sendable {
    private struct StateBox {
        var responses: [String: Data] = [:]
        var error: NetworkError?
        var requestedEndpoints: [Endpoint] = []
    }

    private let state = OSAllocatedUnfairLock(initialState: StateBox())

    /// 경로에 매칭되는 데이터를 등록.
    func setResponse(_ data: Data, forPathContaining fragment: String) {
        state.withLock { $0.responses[fragment] = data }
    }

    func setError(_ error: NetworkError) {
        state.withLock { $0.error = error }
    }

    var requestedEndpoints: [Endpoint] {
        state.withLock { $0.requestedEndpoints }
    }

    func data(for endpoint: Endpoint) async throws -> Data {
        let result: Result<Data, NetworkError> = state.withLock { box in
            box.requestedEndpoints.append(endpoint)
            if let error = box.error { return .failure(error) }
            if let match = box.responses.first(where: { endpoint.path.contains($0.key) })?.value {
                return .success(match)
            }
            return .failure(.invalidResponse)
        }
        return try result.get()
    }
}
