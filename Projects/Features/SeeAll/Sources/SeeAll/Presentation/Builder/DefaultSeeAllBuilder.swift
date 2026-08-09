//
//  DefaultSeeAllBuilder.swift
//  SeeAll
//
//  Created by groot on 7/29/26.
//

import UIKit
import SeeAllInterface
import AppDetailInterface
import ITunesKit
import CoreKit

/// SeeAll 구현 Builder. Core 인프라 + AppDetail 계약을 주입받아 조립한다.
public struct DefaultSeeAllBuilder: SeeAllBuilder {
    private let iTunesClient: ChartFeeding
    private let imageLoader: ImageLoading
    private let appDetail: AppDetailBuilder

    public init(iTunesClient: ChartFeeding, imageLoader: ImageLoading, appDetail: AppDetailBuilder) {
        self.iTunesClient = iTunesClient
        self.imageLoader = imageLoader
        self.appDetail = appDetail
    }

    @MainActor
    public func build(input: SeeAllInput) -> UIViewController {
        let repository = DefaultChartRepository(client: iTunesClient)
        let useCase = DefaultLoadChartUseCase(repository: repository)
        let viewModel = SeeAllViewModel(input: input, useCase: useCase)

        let viewController = SeeAllViewController(viewModel: viewModel, imageLoader: imageLoader)
        let appDetail = appDetail
        viewController.onSelectApp = { [weak viewController] appID in
            guard let viewController else { return }
            let detail = appDetail.build(appID: appID)
            viewController.navigationController?.pushViewController(detail, animated: true)
        }
        return viewController
    }
}
