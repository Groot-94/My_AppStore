//
//  AppDetailSwiftUIFactory.swift
//  AppDetail
//
//  Created by groot on 8/4/26.
//

import ITunesKit
import CoreKit
import Persistence

/// AppDetail SwiftUI 뷰 조립 팩토리. `DefaultAppDetailBuilder` 와 동일한 조립을 `AppDetailView` 로 반환한다.
public enum AppDetailSwiftUIFactory {
    @MainActor
    public static func makeView(
        appID: Int,
        iTunesClient: ITunesClient,
        cache: Cache,
        imageLoader: ImageLoading
    ) -> AppDetailView {
        let repository = DefaultAppDetailRepository(client: iTunesClient, cache: cache)
        let useCase = DefaultLoadAppDetailUseCase(repository: repository)
        let viewModel = AppDetailViewModel(appID: appID, useCase: useCase)
        return AppDetailView(viewModel: viewModel, imageLoader: imageLoader)
    }
}
