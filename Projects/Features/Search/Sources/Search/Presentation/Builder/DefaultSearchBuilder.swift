//
//  DefaultSearchBuilder.swift
//  Search
//
//  Created by groot on 7/29/26.
//

import UIKit
import SearchInterface
import AppDetailInterface
import ITunesKit
import Persistence

/// Search 구현 Builder. Core 인프라 + AppDetail 계약을 주입받아 조립한다.
public struct DefaultSearchBuilder: SearchBuilder {
    private let iTunesClient: ITunesClient
    private let recentSearchStore: RecentSearchStore
    private let imageLoader: ImageLoading
    private let appDetail: AppDetailBuilder

    public init(
        iTunesClient: ITunesClient,
        recentSearchStore: RecentSearchStore,
        imageLoader: ImageLoading,
        appDetail: AppDetailBuilder
    ) {
        self.iTunesClient = iTunesClient
        self.recentSearchStore = recentSearchStore
        self.imageLoader = imageLoader
        self.appDetail = appDetail
    }

    @MainActor
    public func build() -> UIViewController {
        let repository = DefaultSearchRepository(client: iTunesClient)
        let recentSearches = RecentSearchStoreAdapter(store: recentSearchStore)
        let useCase = DefaultSearchAppsUseCase(repository: repository, recentSearches: recentSearches)
        let viewModel = SearchViewModel(useCase: useCase, recentSearches: recentSearches)

        let viewController = SearchViewController(viewModel: viewModel, imageLoader: imageLoader)
        // 결과 행 탭 → AppDetail push. Search 는 AppDetail 구현을 모른다(계약만).
        let appDetail = appDetail
        viewController.onSelectApp = { [weak viewController] appID in
            guard let viewController else { return }
            let detail = appDetail.build(appID: appID)
            viewController.navigationController?.pushViewController(detail, animated: true)
        }
        return viewController
    }
}
