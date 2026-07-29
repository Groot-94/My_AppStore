import Foundation
import Observation

/// UIKit 에서 `@Observable` 상태를 지속 관찰하기 위한 유틸.
///
/// `withObservationTracking` 은 **일회성**이다(추적한 프로퍼티가 다음 번 변경될 때 딱 한 번 콜백).
/// 계속 관찰하려면 콜백 안에서 다시 등록해야 한다. 이 유틸은 그 재귀 재등록을 캡슐화해,
/// SwiftUI 없이도 ViewModel 상태 변화를 반복 수신할 수 있게 한다. 다른 피처도 재사용한다.
///
/// - 콜백은 항상 메인 액터에서 호출된다(UI 갱신 안전).
/// - `cancel()` 또는 인스턴스 해제 시 재등록을 멈춘다.
@MainActor
public final class ObservationSubscription {
    private var isCancelled = false
    private let apply: @MainActor () -> Void

    /// - Parameters:
    ///   - apply: 관찰 대상 프로퍼티를 읽어 UI 를 갱신하는 클로저.
    ///            이 클로저가 접근한 `@Observable` 프로퍼티들이 자동으로 추적 대상이 된다.
    /// - Note: 생성 즉시 한 번 `apply` 를 실행(초기 렌더)하고 추적을 시작한다.
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
        // deinit 는 nonisolated. 플래그만 세우면 다음 onChange 사이클에서 재등록이 멈춘다.
        // (already-cancelled 여부와 무관하게 안전.)
    }
}
