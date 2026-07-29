//
//  ImageLoading.swift
//  CoreKit
//
//  Created by groot on 7/29/26.
//

import Foundation

/// 이미지 로딩 계약. 구현은 Persistence(`DefaultImageLoader`)가 제공하고,
/// UI(DesignSystem)와 피처는 이 계약만 주입받는다.
public protocol ImageLoading: Sendable {
    /// URL 이미지 원본 데이터를 로드한다(캐시 우선).
    func loadImageData(from url: URL) async throws -> Data
}
