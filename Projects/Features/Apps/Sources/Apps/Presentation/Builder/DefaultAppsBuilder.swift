//
//  DefaultAppsBuilder.swift
//  Apps
//
//  Created by groot on 7/29/26.
//

import UIKit
import AppsInterface
import AppDetailInterface
import SeeAllInterface
import ITunesKit
import CoreKit

/// Apps 구현 Builder. Core 인프라 + AppDetail/SeeAll 계약을 주입받아 조립한다.
public struct DefaultAppsBuilder: AppsBuilder {
    private let iTunesClient: AppLookup & ChartFeeding
    private let imageLoader: ImageLoading
    private let appDetail: AppDetailBuilder
    private let seeAll: SeeAllBuilder

    public init(
        iTunesClient: AppLookup & ChartFeeding,
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
        let repository = DefaultAppsRepository(client: iTunesClient)
        let useCase = DefaultLoadAppsFeedUseCase(repository: repository)
        let viewModel = AppsViewModel(useCase: useCase)

        let viewController = AppsViewController(viewModel: viewModel, imageLoader: imageLoader)
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
