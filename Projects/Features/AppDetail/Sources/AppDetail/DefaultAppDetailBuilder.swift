import UIKit
import AppDetailInterface

/// AppDetail 구현 Builder. M0 은 placeholder 화면만 반환한다.
public struct DefaultAppDetailBuilder: AppDetailBuilder {
    public init() {}

    public func build(appID: Int) -> UIViewController {
        PlaceholderViewController(label: "AppDetail (appID: \(appID))")
    }
}
