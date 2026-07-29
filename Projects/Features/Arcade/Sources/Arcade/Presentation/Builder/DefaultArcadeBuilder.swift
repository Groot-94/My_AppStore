//
//  DefaultArcadeBuilder.swift
//  Arcade
//
//  Created by groot on 7/29/26.
//

import UIKit
import ArcadeInterface
import AppDetailInterface
import ITunesKit
import Persistence

/// Arcade 구현 Builder. Core 인프라 + AppDetail 계약을 주입받아 조립한다.
public struct DefaultArcadeBuilder: ArcadeBuilder {
    private let iTunesClient: ITunesClient
    private let imageLoader: ImageLoading
    private let appDetail: AppDetailBuilder

    public init(
        iTunesClient: ITunesClient,
        imageLoader: ImageLoading,
        appDetail: AppDetailBuilder
    ) {
        self.iTunesClient = iTunesClient
        self.imageLoader = imageLoader
        self.appDetail = appDetail
    }

    @MainActor
    public func build() -> UIViewController {
        let repository = DefaultArcadeRepository(client: iTunesClient)
        let useCase = DefaultLoadArcadeFeedUseCase(repository: repository)
        let viewModel = ArcadeViewModel(useCase: useCase)

        let viewController = ArcadeViewController(viewModel: viewModel, imageLoader: imageLoader)
        let appDetail = appDetail
        viewController.onSelectApp = { [weak viewController] appID in
            guard let viewController else { return }
            viewController.navigationController?.pushViewController(appDetail.build(appID: appID), animated: true)
        }
        return viewController
    }
}
