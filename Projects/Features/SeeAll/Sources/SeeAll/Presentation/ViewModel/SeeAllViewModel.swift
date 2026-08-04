//
//  SeeAllViewModel.swift
//  SeeAll
//
//  Created by groot on 7/29/26.
//

import Foundation
import Observation
import CoreKit
import SeeAllInterface

/// 차트 전체 목록 ViewModel. UI 프레임워크 비의존(@Observable + @MainActor).
///
/// 상태 전이: loading → loaded / empty / failed. 빈 결과는 상태로 표현한다.
@Observable
@MainActor
public final class SeeAllViewModel {
    public enum State: Sendable, Equatable {
        case loading
        case loaded([SeeAllItem])
        case empty
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
            state = items.isEmpty ? .empty : .loaded(items)
        } catch {
            state = .failed(CommonStrings.Error.networkBody)
        }
    }
}
