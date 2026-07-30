//
//  TodayViewModel.swift
//  Today
//
//  Created by groot on 7/29/26.
//

import Foundation
import Observation
import CoreKit
import DesignSystem

/// Today 탭 ViewModel. UI 프레임워크 비의존(@Observable + @MainActor).
///
/// 상태 전이: loading → loaded / failed. refresh 는 실패 시 기존 loaded 카드를 유지한다.
/// 큐레이션 부재/파싱 실패(`CoreError.notFound`)와 네트워크 실패를 다른 문구로 구분한다.
@Observable
@MainActor
public final class TodayViewModel {
    public enum State: Sendable, Equatable {
        case loading
        case loaded([TodayCard])
        case failed(String)
    }

    public private(set) var state: State = .loading

    private let useCase: LoadTodayFeedUseCase

    public init(useCase: LoadTodayFeedUseCase) {
        self.useCase = useCase
    }

    public func load() async {
        state = .loading
        await fetch(keepOnFailure: false)
    }

    /// Pull-to-refresh. 기존 카드를 유지한 채 재조회하고, 실패 시 기존 카드를 그대로 둔다.
    public func refresh() async {
        await fetch(keepOnFailure: true)
    }

    private func fetch(keepOnFailure: Bool) async {
        do {
            let cards = try await useCase.execute()
            state = .loaded(cards)
        } catch {
            if keepOnFailure, case .loaded = state { return }
            if case CoreError.notFound = error {
                state = .failed("추천 콘텐츠를 준비하지 못했습니다.")
            } else {
                state = .failed(CommonStrings.Error.networkBody)
            }
        }
    }
}
