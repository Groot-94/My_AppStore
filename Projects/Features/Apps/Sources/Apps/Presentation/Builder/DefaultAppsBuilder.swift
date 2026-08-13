//
//  DefaultAppsBuilder.swift
//  Apps
//
//  Created by groot on 7/29/26.
//

import UIKit
import AppsInterface
import ITunesKit
import CoreKit

/// Apps 구현 Builder. Core 인프라 + 자기 Routing delegate 를 주입받아 조립한다.
public struct DefaultAppsBuilder: AppsBuilder {
    private let iTunesClient: AppLookup & ChartFeeding
    private let imageLoader: ImageLoading
    private weak var router: AppsRouting?

    public init(
        iTunesClient: AppLookup & ChartFeeding,
        imageLoader: ImageLoading,
        router: AppsRouting
    ) {
        self.iTunesClient = iTunesClient
        self.imageLoader = imageLoader
        self.router = router
    }

    @MainActor
    public func build() -> UIViewController {
        let repository = DefaultAppsRepository(client: iTunesClient)
        let useCase = DefaultLoadAppsFeedUseCase(repository: repository)
        let viewModel = AppsViewModel(useCase: useCase)

        let viewController = AppsViewController(viewModel: viewModel, imageLoader: imageLoader)
        viewController.router = router
        return viewController
    }
}
