//
//  AppDetailViewModel.swift
//  AppDetail
//
//  Created by groot on 7/29/26.
//

import Foundation
import Observation
import CoreKit

/// 앱 상세 화면 ViewModel. UI 프레임워크 비의존(@Observable + @MainActor).
///
/// 상태 전이: loading → loaded / failed.
/// 0건(notFound)과 네트워크 실패를 다른 문구로 구분한다(0건은 재시도 무의미).
@Observable
@MainActor
public final class AppDetailViewModel {
    public enum State: Sendable, Equatable {
        case loading
        case loaded(AppDetail)
        case failed(String)
    }

    public private(set) var state: State = .loading
    public let appID: Int

    /// 재시도 가능 여부. 0건(notFound)은 재시도해도 결과가 같아 false.
    public private(set) var isRetryable = false

    private let useCase: LoadAppDetailUseCase

    public init(appID: Int, useCase: LoadAppDetailUseCase) {
        self.appID = appID
        self.useCase = useCase
    }

    /// 상세 로드. 화면 진입/재시도 시 호출.
    public func load() async {
        state = .loading
        isRetryable = false
        do {
            let detail = try await useCase.execute(appID: appID)
            state = .loaded(detail)
        } catch CoreError.notFound {
            state = .failed("앱을 찾을 수 없음")
        } catch {
            isRetryable = true
            state = .failed("불러올 수 없습니다. 네트워크를 확인하세요.")
        }
    }
}
