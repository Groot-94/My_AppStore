//
//  DefaultSearchBuilder.swift
//  Search
//
//  Created by groot on 7/29/26.
//

import UIKit
import SearchInterface
import ITunesKit
import CoreKit
import Persistence

/// Search 구현 Builder. Core 인프라 + 자기 Routing delegate 를 주입받아 조립한다.
public struct DefaultSearchBuilder: SearchBuilder {
    private let iTunesClient: AppSearching
    private let recentSearchStore: RecentSearchStore
    private let imageLoader: ImageLoading
    private weak var router: SearchRouting?

    public init(
        iTunesClient: AppSearching,
        recentSearchStore: RecentSearchStore,
        imageLoader: ImageLoading,
        router: SearchRouting
    ) {
        self.iTunesClient = iTunesClient
        self.recentSearchStore = recentSearchStore
        self.imageLoader = imageLoader
        self.router = router
    }

    @MainActor
    public func build() -> UIViewController {
        let repository = DefaultSearchRepository(client: iTunesClient)
        let recentSearches = RecentSearchStoreAdapter(store: recentSearchStore)
        let useCase = DefaultSearchAppsUseCase(repository: repository, recentSearches: recentSearches)
        let viewModel = SearchViewModel(useCase: useCase)

        let viewController = SearchViewController(viewModel: viewModel, imageLoader: imageLoader)
        viewController.router = router
        return viewController
    }
}
