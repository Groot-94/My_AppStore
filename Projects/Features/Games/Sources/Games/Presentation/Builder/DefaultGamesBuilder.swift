//
//  DefaultGamesBuilder.swift
//  Games
//
//  Created by groot on 7/29/26.
//

import UIKit
import GamesInterface
import ITunesKit
import CoreKit

/// Games 구현 Builder. Core 인프라 + 자기 Routing delegate 를 주입받아 조립한다.
public struct DefaultGamesBuilder: GamesBuilder {
    private let iTunesClient: AppLookup & ChartFeeding
    private let imageLoader: ImageLoading
    private weak var router: GamesRouting?

    public init(
        iTunesClient: AppLookup & ChartFeeding,
        imageLoader: ImageLoading,
        router: GamesRouting
    ) {
        self.iTunesClient = iTunesClient
        self.imageLoader = imageLoader
        self.router = router
    }

    @MainActor
    public func build() -> UIViewController {
        let repository = DefaultGamesRepository(client: iTunesClient)
        let useCase = DefaultLoadGamesFeedUseCase(repository: repository)
        let viewModel = GamesViewModel(useCase: useCase)

        let viewController = GamesViewController(viewModel: viewModel, imageLoader: imageLoader)
        viewController.router = router
        return viewController
    }
}
