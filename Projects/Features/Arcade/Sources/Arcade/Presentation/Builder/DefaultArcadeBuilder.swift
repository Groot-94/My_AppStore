//
//  DefaultArcadeBuilder.swift
//  Arcade
//
//  Created by groot on 7/29/26.
//

import UIKit
import ArcadeInterface
import ITunesKit
import CoreKit

/// Arcade 구현 Builder. Core 인프라 + 자기 Routing delegate 를 주입받아 조립한다.
public struct DefaultArcadeBuilder: ArcadeBuilder {
    private let iTunesClient: AppLookup
    private let imageLoader: ImageLoading
    private weak var router: ArcadeRouting?

    public init(
        iTunesClient: AppLookup,
        imageLoader: ImageLoading,
        router: ArcadeRouting
    ) {
        self.iTunesClient = iTunesClient
        self.imageLoader = imageLoader
        self.router = router
    }

    @MainActor
    public func build() -> UIViewController {
        let repository = DefaultArcadeRepository(client: iTunesClient)
        let useCase = DefaultLoadArcadeFeedUseCase(repository: repository)
        let viewModel = ArcadeViewModel(useCase: useCase)

        let viewController = ArcadeViewController(viewModel: viewModel, imageLoader: imageLoader)
        viewController.router = router
        return viewController
    }
}
