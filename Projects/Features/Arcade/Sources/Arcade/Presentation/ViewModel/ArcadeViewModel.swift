//
//  ArcadeViewModel.swift
//  Arcade
//
//  Created by groot on 7/29/26.
//

import Foundation
import Observation

/// Arcade 탭 ViewModel. UI 프레임워크 비의존(@Observable + @MainActor).
///
/// 상태 전이: loading → loaded / failed. 빈 큐레이션은 loaded(빈 피드)로 표현.
@Observable
@MainActor
public final class ArcadeViewModel {
    public enum State: Sendable, Equatable {
        case loading
        case loaded(ArcadeFeed)
        case failed(String)
    }

    public private(set) var state: State = .loading

    private let useCase: LoadArcadeFeedUseCase

    public init(useCase: LoadArcadeFeedUseCase) {
        self.useCase = useCase
    }

    public func load() async {
        state = .loading
        do {
            let feed = try await useCase.execute()
            state = .loaded(feed)
        } catch {
            state = .failed("불러올 수 없습니다. 네트워크를 확인하세요.")
        }
    }
}
