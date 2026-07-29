import Foundation
import os

/// 간단 로거. `os.Logger` 래퍼로 서브시스템/카테고리 단위 로그를 낸다.
///
/// Core 는 UI/네트워크 세부에 비의존이므로 로거도 순수 Foundation + os 만 사용한다.
public struct Log: Sendable {
    private let logger: os.Logger

    public init(subsystem: String = "com.groot94.myappstore", category: String) {
        self.logger = os.Logger(subsystem: subsystem, category: category)
    }

    public func debug(_ message: String) {
        logger.debug("\(message, privacy: .public)")
    }

    public func info(_ message: String) {
        logger.info("\(message, privacy: .public)")
    }

    public func error(_ message: String) {
        logger.error("\(message, privacy: .public)")
    }
}
