//
//  DefaultGamesBuilder.swift
//  Games
//
//  Created by groot on 7/29/26.
//

import UIKit
import GamesInterface
import AppDetailInterface
import SeeAllInterface
import ITunesKit
import Persistence

/// Games 구현 Builder. Core 인프라 + AppDetail/SeeAll 계약을 주입받아 조립한다.
public struct DefaultGamesBuilder: GamesBuilder {
    private let iTunesClient: ITunesClient
    private let imageLoader: ImageLoading
    private let appDetail: AppDetailBuilder
    private let seeAll: SeeAllBuilder

    public init(
        iTunesClient: ITunesClient,
        imageLoader: ImageLoading,
        appDetail: AppDetailBuilder,
        seeAll: SeeAllBuilder
    ) {
        self.iTunesClient = iTunesClient
        self.imageLoader = imageLoader
        self.appDetail = appDetail
        self.seeAll = seeAll
    }

    @MainActor
    public func build() -> UIViewController {
        let repository = DefaultGamesRepository(client: iTunesClient)
        let useCase = DefaultLoadGamesFeedUseCase(repository: repository)
        let viewModel = GamesViewModel(useCase: useCase)

        let viewController = GamesViewController(viewModel: viewModel, imageLoader: imageLoader)
        let appDetail = appDetail
        let seeAll = seeAll
        viewController.onSelectApp = { [weak viewController] appID in
            guard let viewController else { return }
            viewController.navigationController?.pushViewController(appDetail.build(appID: appID), animated: true)
        }
        viewController.onSeeAll = { [weak viewController] input in
            guard let viewController else { return }
            viewController.navigationController?.pushViewController(seeAll.build(input: input), animated: true)
        }
        return viewController
    }
}
