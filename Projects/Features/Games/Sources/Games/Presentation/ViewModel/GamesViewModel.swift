//
//  GamesViewModel.swift
//  Games
//
//  Created by groot on 7/29/26.
//

import Foundation
import Observation
import DesignSystem

/// Games 탭 ViewModel. UI 프레임워크 비의존(@Observable + @MainActor).
///
/// 상태 전이: loading → loaded / failed. 부분 성공은 loaded(빈 섹션 포함)로 표현.
@Observable
@MainActor
public final class GamesViewModel {
    public enum State: Sendable, Equatable {
        case loading
        case loaded(GamesFeed)
        case failed(String)
    }

    public private(set) var state: State = .loading

    private let useCase: LoadGamesFeedUseCase

    public init(useCase: LoadGamesFeedUseCase) {
        self.useCase = useCase
    }

    public func load() async {
        state = .loading
        do {
            let feed = try await useCase.execute()
            state = .loaded(feed)
        } catch {
            state = .failed(CommonStrings.Error.networkBody)
        }
    }
}
