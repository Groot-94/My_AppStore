//
//  ObservationSubscription.swift
//  DesignSystem
//
//  Created by groot on 7/29/26.
//

import Foundation
import Observation

/// UIKit 에서 `@Observable` 상태를 지속 관찰하기 위한 유틸.
///
/// `withObservationTracking` 은 일회성이라 변경 콜백마다 다시 등록해야 계속 관찰된다.
/// 이 유틸은 그 재귀 재등록을 캡슐화한다. 콜백은 항상 메인 액터에서 호출된다.
@MainActor
public final class ObservationSubscription {
    private var isCancelled = false
    private let apply: @MainActor () -> Void

    /// - Parameter apply: 관찰 대상 프로퍼티를 읽어 UI 를 갱신하는 클로저(생성 즉시 1회 실행).
    public init(_ apply: @escaping @MainActor () -> Void) {
        self.apply = apply
        track()
    }

    private func track() {
        guard !isCancelled else { return }
        withObservationTracking {
            apply()
        } onChange: { [weak self] in
            // onChange 는 임의 스레드에서 올 수 있으므로 메인으로 옮겨 재등록한다.
            Task { @MainActor in
                guard let self, !self.isCancelled else { return }
                self.track()
            }
        }
    }

    /// 관찰 중단.
    public func cancel() {
        isCancelled = true
    }

    deinit {
        // deinit 는 nonisolated — 플래그만 세우면 다음 onChange 사이클에서 재등록이 멈춘다.
    }
}
