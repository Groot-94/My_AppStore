//
//  ArcadeViewModel.swift
//  Arcade
//
//  Created by groot on 7/29/26.
//

import Foundation
import Observation
import CoreKit
import DesignSystem

/// Arcade 탭 ViewModel. UI 프레임워크 비의존(@Observable + @MainActor).
///
/// 상태 전이: loading → loaded / failed. 빈 큐레이션은 loaded(빈 피드)로 표현.
/// 큐레이션 부재/파싱 실패(`CoreError.notFound`)와 네트워크 실패를 다른 문구로 구분한다.
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
        } catch CoreError.notFound {
            state = .failed("Arcade 콘텐츠를 준비하지 못했습니다.")
        } catch {
            state = .failed(CommonStrings.Error.networkBody)
        }
    }
}
