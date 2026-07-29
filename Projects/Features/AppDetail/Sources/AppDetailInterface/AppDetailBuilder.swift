import UIKit

/// AppDetail 진입 계약. 다른 피처/App 이 보는 유일한 표면.
public protocol AppDetailBuilder {
    func build(appID: Int) -> UIViewController
}
