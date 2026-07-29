import Foundation
import os

/// 간단 로거 스텁. M1 에서 레벨/카테고리 확장 예정.
public struct Log: Sendable {
    private let logger: os.Logger

    public init(subsystem: String = "com.groot94.myappstore", category: String) {
        self.logger = os.Logger(subsystem: subsystem, category: category)
    }

    public func debug(_ message: String) {
        logger.debug("\(message, privacy: .public)")
    }

    public func error(_ message: String) {
        logger.error("\(message, privacy: .public)")
    }
}
