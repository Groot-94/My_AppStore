import UIKit
import CoreKit
// 피처 Impl (App 만 구현을 안다) + Interface(계약 타입)
import AppDetail
import AppDetailInterface
import SeeAll
import SeeAllInterface
import Search
import Today
import Apps
import Games
import Arcade

/// Composition Root.
/// DI 컨테이너 구성 + 각 피처 Builder 구현체 생성 + 상호 계약 주입 + 탭 조립.
struct AppComposition {

    /// DI 컨테이너 구성(M0: StoreConfig 등록 정도).
    private func makeContainer() -> DIContainer {
        let container = DIContainer()
        container.register(StoreConfig.self) { .korea }
        return container
    }

    func makeRootTabBarController() -> UITabBarController {
        _ = makeContainer() // M0: 구성만 확인. Core 구현 등록은 M1.

        // 1) 타 피처가 계약으로 주입받는 Builder 구현체 생성.
        let appDetailBuilder: AppDetailBuilder = DefaultAppDetailBuilder()
        let seeAllBuilder: SeeAllBuilder = DefaultSeeAllBuilder(appDetail: appDetailBuilder)

        // 2) 각 탭 피처 Builder 에 계약 주입.
        let todayBuilder = DefaultTodayBuilder(appDetail: appDetailBuilder)
        let gamesBuilder = DefaultGamesBuilder(appDetail: appDetailBuilder, seeAll: seeAllBuilder)
        let appsBuilder = DefaultAppsBuilder(appDetail: appDetailBuilder, seeAll: seeAllBuilder)
        let arcadeBuilder = DefaultArcadeBuilder(appDetail: appDetailBuilder)
        let searchBuilder = DefaultSearchBuilder(appDetail: appDetailBuilder)

        // 3) 탭 순서: [Today | Games | Apps | Arcade | Search]
        let tabs: [(title: String, symbol: String, root: UIViewController)] = [
            ("투데이", "doc.text.image", todayBuilder.build()),
            ("게임", "gamecontroller", gamesBuilder.build()),
            ("앱", "square.stack.3d.up", appsBuilder.build()),
            ("아케이드", "arcade.stick", arcadeBuilder.build()),
            ("검색", "magnifyingglass", searchBuilder.build()),
        ]

        let controllers = tabs.map { tab -> UIViewController in
            let nav = UINavigationController(rootViewController: tab.root)
            nav.tabBarItem = UITabBarItem(
                title: tab.title,
                image: UIImage(systemName: tab.symbol),
                selectedImage: nil
            )
            return nav
        }

        let tabBar = UITabBarController()
        tabBar.viewControllers = controllers
        return tabBar
    }
}
