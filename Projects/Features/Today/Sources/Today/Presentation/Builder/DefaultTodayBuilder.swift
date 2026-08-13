//
//  DefaultTodayBuilder.swift
//  Today
//
//  Created by groot on 7/29/26.
//

import UIKit
import TodayInterface
import ITunesKit
import CoreKit

/// Today 구현 Builder. Core 인프라 + 자기 Routing delegate 를 주입받아 조립한다.
public struct DefaultTodayBuilder: TodayBuilder {
    private let iTunesClient: AppLookup
    private let imageLoader: ImageLoading
    private weak var router: TodayRouting?

    public init(
        iTunesClient: AppLookup,
        imageLoader: ImageLoading,
        router: TodayRouting
    ) {
        self.iTunesClient = iTunesClient
        self.imageLoader = imageLoader
        self.router = router
    }

    @MainActor
    public func build() -> UIViewController {
        let repository = DefaultTodayRepository(client: iTunesClient)
        let useCase = DefaultLoadTodayFeedUseCase(repository: repository)
        let viewModel = TodayViewModel(useCase: useCase)

        let viewController = TodayViewController(viewModel: viewModel, imageLoader: imageLoader)
        viewController.router = router
        return viewController
    }
}
