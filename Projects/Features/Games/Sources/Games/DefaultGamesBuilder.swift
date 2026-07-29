import UIKit
import GamesInterface
import AppDetailInterface
import SeeAllInterface

/// Games 구현 Builder. AppDetail + SeeAll 계약을 생성자 주입받는다.
public struct DefaultGamesBuilder: GamesBuilder {
    private let appDetail: AppDetailBuilder
    private let seeAll: SeeAllBuilder

    public init(appDetail: AppDetailBuilder, seeAll: SeeAllBuilder) {
        self.appDetail = appDetail
        self.seeAll = seeAll
    }

    public func build() -> UIViewController {
        PlaceholderViewController(label: "Games")
    }
}
