import Foundation
import CoreKit

/// 범용 HTTP 통신 추상화(iTunes 를 모르는 계층). M1 에서 구현.
///
/// 최소 시그니처만 선언한다 — 구현은 M1 범위.
public protocol NetworkClient: Sendable {
    /// 주어진 URL 에서 데이터를 가져온다.
    func data(from url: URL) async throws -> Data
}

/// 네트워크 계층 에러 스텁. 피처가 사용자용 메시지로 변환한다.
public enum NetworkError: Error, Sendable {
    case invalidResponse
    case decodingFailed
    case transport
}
