//
//  DefaultAppDetailBuilder.swift
//  AppDetail
//
//  Created by groot on 7/29/26.
//

import UIKit
import AppDetailInterface
import ITunesKit
import CoreKit
import Persistence

/// AppDetail 구현 Builder. Core 인프라(ITunesClient/Cache/ImageLoading)를 주입받아 조립한다.
public struct DefaultAppDetailBuilder: AppDetailBuilder {
    private let iTunesClient: ITunesClient
    private let cache: Cache
    private let imageLoader: ImageLoading
    private let now: Date

    public init(iTunesClient: ITunesClient, cache: Cache, imageLoader: ImageLoading, now: Date = Date()) {
        self.iTunesClient = iTunesClient
        self.cache = cache
        self.imageLoader = imageLoader
        self.now = now
    }

    @MainActor
    public func build(appID: Int) -> UIViewController {
        let repository = DefaultAppDetailRepository(client: iTunesClient, cache: cache)
        let useCase = DefaultLoadAppDetailUseCase(repository: repository)
        let viewModel = AppDetailViewModel(appID: appID, useCase: useCase, now: now)
        return AppDetailViewController(viewModel: viewModel, imageLoader: imageLoader)
    }
}
