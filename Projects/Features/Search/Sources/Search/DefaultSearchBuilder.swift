import UIKit
import SearchInterface
import AppDetailInterface

/// Search 구현 Builder. AppDetail 계약을 생성자 주입받는다.
public struct DefaultSearchBuilder: SearchBuilder {
    private let appDetail: AppDetailBuilder

    public init(appDetail: AppDetailBuilder) {
        self.appDetail = appDetail
    }

    public func build() -> UIViewController {
        PlaceholderViewController(label: "Search")
    }
}
