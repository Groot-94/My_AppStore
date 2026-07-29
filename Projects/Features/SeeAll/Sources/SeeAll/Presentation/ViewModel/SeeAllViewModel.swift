//
//  SeeAllViewModel.swift
//  SeeAll
//
//  Created by groot on 7/29/26.
//

import Foundation
import Observation
import SeeAllInterface

/// 차트 전체 목록 ViewModel. UI 프레임워크 비의존(@Observable + @MainActor).
///
/// 상태 전이: loading → loaded / failed. 필터 후 빈 결과는 loaded([])로 안내 문구 위임.
@Observable
@MainActor
public final class SeeAllViewModel {
    public enum State: Sendable, Equatable {
        case loading
        case loaded([SeeAllItem])
        case failed(String)
    }

    public private(set) var state: State = .loading
    public let input: SeeAllInput

    private let useCase: LoadChartUseCase

    public init(input: SeeAllInput, useCase: LoadChartUseCase) {
        self.input = input
        self.useCase = useCase
    }

    public func load() async {
        state = .loading
        do {
            let items = try await useCase.execute(input: input)
            state = .loaded(items)
        } catch {
            state = .failed("불러올 수 없습니다. 네트워크를 확인하세요.")
        }
    }
}
