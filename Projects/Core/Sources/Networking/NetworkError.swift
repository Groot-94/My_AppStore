import Foundation

/// 네트워크 계층 에러. 전송 실패 / HTTP 상태 / 디코딩 실패를 구분한다.
///
/// 피처가 사용자용 메시지로 변환한다(docs/07). Core 는 이 도메인 에러만 던진다.
public enum NetworkError: Error, Sendable, Equatable {
    /// 요청 URL 을 구성하지 못함(잘못된 컴포넌트).
    case invalidURL
    /// 전송 실패(연결 끊김/타임아웃 등 `URLError`).
    case transport(URLError)
    /// HTTP 응답이지만 성공 범위(200..<300) 밖.
    case unacceptableStatus(code: Int)
    /// 응답이 `HTTPURLResponse` 가 아님.
    case invalidResponse
    /// 본문 디코딩 실패.
    case decodingFailed

    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.decodingFailed, .decodingFailed):
            return true
        case let (.transport(l), .transport(r)):
            return l.code == r.code
        case let (.unacceptableStatus(l), .unacceptableStatus(r)):
            return l == r
        default:
            return false
        }
    }
}
