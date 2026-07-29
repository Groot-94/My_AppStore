import UIKit
import SeeAllInterface
import AppDetailInterface

/// SeeAll 구현 Builder. 타 피처 계약(AppDetail)을 생성자 주입받는다.
public struct DefaultSeeAllBuilder: SeeAllBuilder {
    private let appDetail: AppDetailBuilder

    public init(appDetail: AppDetailBuilder) {
        self.appDetail = appDetail
    }

    public func build(input: SeeAllInput) -> UIViewController {
        PlaceholderViewController(label: "SeeAll — \(input.title)")
    }
}
