//
//  Logger.swift
//  CoreKit
//
//  Created by groot on 7/29/26.
//

import Foundation
import os

/// `os.Logger` 래퍼. 서브시스템/카테고리 단위 로그.
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
