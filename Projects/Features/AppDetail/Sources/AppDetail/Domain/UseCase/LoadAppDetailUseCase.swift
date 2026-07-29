//
//  LoadAppDetailUseCase.swift
//  AppDetail
//
//  Created by groot on 7/29/26.
//

import Foundation

/// 앱 상세 로드 UseCase 계약.
public protocol LoadAppDetailUseCase: Sendable {
    /// appID 로 상세를 로드한다.
    /// - Throws: Repository 에러 전파(0건은 `CoreError.notFound`).
    func execute(appID: Int) async throws -> AppDetail
}

/// 기본 구현. Repository 에 그대로 위임한다.
public struct DefaultLoadAppDetailUseCase: LoadAppDetailUseCase {
    private let repository: AppDetailRepository

    public init(repository: AppDetailRepository) {
        self.repository = repository
    }

    public func execute(appID: Int) async throws -> AppDetail {
        try await repository.fetch(appID: appID)
    }
}
