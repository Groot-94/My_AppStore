import Foundation

/// Core 계층 공통 도메인 에러 스텁.
///
/// 네트워크/디코딩 에러는 Networking 이 던지고, 피처가 사용자용 메시지로 변환한다(docs/07).
/// Core 는 도메인/네트워크 에러만 표현한다.
public enum CoreError: Error, Sendable {
    /// 유효하지 않은 입력.
    case invalidInput
    /// 결과 없음(에러 아님 상태와 구분하기 위한 도메인 신호).
    case notFound
    /// 미분류 실패.
    case unknown
}
