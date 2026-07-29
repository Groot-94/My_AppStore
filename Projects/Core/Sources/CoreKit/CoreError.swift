//
//  CoreError.swift
//  CoreKit
//
//  Created by groot on 7/29/26.
//

import Foundation

/// Core 계층 공통 도메인 에러.
public enum CoreError: Error, Sendable {
    /// 유효하지 않은 입력.
    case invalidInput
    /// 결과 없음(에러 아님 상태와 구분하기 위한 도메인 신호).
    case notFound
    /// 미분류 실패.
    case unknown
}
