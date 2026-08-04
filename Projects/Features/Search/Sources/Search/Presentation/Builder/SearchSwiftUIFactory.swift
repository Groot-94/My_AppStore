//
//  SearchSwiftUIFactory.swift
//  Search
//
//  Created by groot on 8/4/26.
//

import ITunesKit
import CoreKit
import Persistence

/// Search SwiftUI 뷰 조립 팩토리. `DefaultSearchBuilder` 와 동일한 조립을 `SearchView` 로 반환한다.
public enum SearchSwiftUIFactory {
    @MainActor
    public static func makeView(
        iTunesClient: ITunesClient,
        recentSearchStore: RecentSearchStore,
        imageLoader: ImageLoading,
        onSelectApp: @escaping (Int) -> Void,
        initialTerm: String? = nil
    ) -> SearchView {
        let repository = DefaultSearchRepository(client: iTunesClient)
        let recentSearches = RecentSearchStoreAdapter(store: recentSearchStore)
        let useCase = DefaultSearchAppsUseCase(repository: repository, recentSearches: recentSearches)
        let viewModel = SearchViewModel(useCase: useCase)
        return SearchView(
            viewModel: viewModel,
            imageLoader: imageLoader,
            onSelectApp: onSelectApp,
            initialTerm: initialTerm
        )
    }
}
