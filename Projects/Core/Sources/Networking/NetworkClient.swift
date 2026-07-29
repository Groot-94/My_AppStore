import Foundation
import CoreKit

/// 범용 HTTP 통신 추상화(iTunes 를 모르는 계층).
///
/// `Endpoint` 를 받아 원본 `Data` 를 반환한다. 디코딩은 프로토콜 확장이 제공한다.
public protocol NetworkClient: Sendable {
    /// 엔드포인트에서 원본 응답 바디를 가져온다.
    func data(for endpoint: Endpoint) async throws -> Data
}

public extension NetworkClient {
    /// 엔드포인트 응답을 `Decodable` 타입으로 디코딩한다.
    /// 디코딩 실패는 `NetworkError.decodingFailed` 로 매핑된다.
    func decode<T: Decodable>(
        _ type: T.Type,
        from endpoint: Endpoint,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let data = try await data(for: endpoint)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}

// MARK: - 재시도 정책

/// 전송 실패 시 재시도 정책. 기본은 1회(단순).
public struct RetryPolicy: Sendable, Equatable {
    /// 최초 시도 이후 추가 재시도 횟수.
    public let maxRetries: Int

    public init(maxRetries: Int) {
        self.maxRetries = max(0, maxRetries)
    }

    /// 재시도 없음.
    public static let none = RetryPolicy(maxRetries: 0)
    /// 단순 1회 재시도(기본).
    public static let single = RetryPolicy(maxRetries: 1)
}

// MARK: - URLSession 추상화 (테스트 주입 지점)

/// `URLSession.data(for:)` 를 감싸는 최소 추상화.
///
/// 테스트에서 `URLProtocol` 목 없이도 스텁을 주입할 수 있게 한다.
public protocol HTTPDataFetching: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: HTTPDataFetching {}
