//
//  CommonStrings.swift
//  CoreKit
//
//  Created by groot on 7/30/26.
//

import Foundation

/// 여러 피처가 공유하는 표시 문자열 상수 집합.
///
/// CoreError→문구 결정 로직은 각 피처 VM 이 소유하고, 여기서는 순수 문자열만 제공한다.
public enum CommonStrings {
    public enum Error {
        public static let networkBody = "불러올 수 없습니다. 네트워크를 확인하세요."
        public static let loadFailedTitle = "불러올 수 없음"
    }

    public enum Price {
        public static let free = "무료"
    }

    public enum Action {
        public static let open = "열기"
    }
}
