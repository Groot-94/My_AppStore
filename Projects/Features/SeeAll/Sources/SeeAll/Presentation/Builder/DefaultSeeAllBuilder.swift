//
//  DefaultSeeAllBuilder.swift
//  SeeAll
//
//  Created by groot on 7/29/26.
//

import UIKit
import SeeAllInterface
import ITunesKit
import CoreKit

/// SeeAll 구현 Builder. Core 인프라 + 자기 Routing delegate 를 주입받아 조립한다.
public struct DefaultSeeAllBuilder: SeeAllBuilder {
    private let iTunesClient: ChartFeeding
    private let imageLoader: ImageLoading
    private weak var router: SeeAllRouting?

    public init(iTunesClient: ChartFeeding, imageLoader: ImageLoading, router: SeeAllRouting) {
        self.iTunesClient = iTunesClient
        self.imageLoader = imageLoader
        self.router = router
    }

    @MainActor
    public func build(input: SeeAllInput) -> UIViewController {
        let repository = DefaultChartRepository(client: iTunesClient)
        let useCase = DefaultLoadChartUseCase(repository: repository)
        let viewModel = SeeAllViewModel(input: input, useCase: useCase)

        let viewController = SeeAllViewController(viewModel: viewModel, imageLoader: imageLoader)
        viewController.router = router
        return viewController
    }
}
