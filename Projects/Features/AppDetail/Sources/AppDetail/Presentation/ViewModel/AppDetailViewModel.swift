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
/// 0건(notFound)과 네트워크 실패를 다른 문구로 구분하고, retryable 로 재시도 가능 여부를 표현한다.
/// failed 문자열은 본문(body)이며, 타이틀은 View 가 결정한다(타 피처와 동일 계약).
@Observable
@MainActor
public final class AppDetailViewModel {
    public enum State: Sendable, Equatable {
        case loading
        case loaded(AppDetailPresentation)
        case failed(message: String, retryable: Bool)
    }

    public private(set) var state: State = .loading
    public let appID: Int

    private let useCase: LoadAppDetailUseCase
    /// 상대 날짜 기준 시각. Presentation 결정성 확보를 위해 주입.
    private let now: Date

    public init(appID: Int, useCase: LoadAppDetailUseCase, now: Date = Date()) {
        self.appID = appID
        self.useCase = useCase
        self.now = now
    }

    /// 상세 로드. 화면 진입/재시도 시 호출.
    public func load() async {
        state = .loading
        do {
            let detail = try await useCase.execute(appID: appID)
            state = .loaded(AppDetailPresentation(detail: detail, now: now))
        } catch CoreError.notFound {
            state = .failed(message: "삭제되었거나 이 지역에서 제공되지 않는 앱입니다.", retryable: false)
        } catch {
            state = .failed(message: CommonStrings.Error.networkBody, retryable: true)
        }
    }
}
