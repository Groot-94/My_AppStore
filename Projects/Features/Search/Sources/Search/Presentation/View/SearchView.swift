//
//  SearchView.swift
//  Search
//
//  Created by groot on 8/4/26.
//

import SwiftUI
import CoreKit

/// 검색 화면 SwiftUI 뷰. UIKit `SearchViewController` 와 동일한 `SearchViewModel` 을 재사용한다.
public struct SearchView: View {
    @State private var viewModel: SearchViewModel
    private let imageLoader: ImageLoading
    private let onSelectApp: (Int) -> Void
    /// 스크린샷/UITest 지원: 진입 시 자동 검색할 초기어(없으면 idle 유지).
    private let initialTerm: String?

    @State private var term = ""

    public init(
        viewModel: SearchViewModel,
        imageLoader: ImageLoading,
        onSelectApp: @escaping (Int) -> Void,
        initialTerm: String? = nil
    ) {
        _viewModel = State(wrappedValue: viewModel)
        self.imageLoader = imageLoader
        self.onSelectApp = onSelectApp
        self.initialTerm = initialTerm
    }

    public var body: some View {
        content
            .navigationTitle("검색")
            .searchable(text: $term, prompt: "게임, 앱, 스토리 등")
            .onSubmit(of: .search) {
                Task { await viewModel.search(term: term) }
            }
            .task {
                await viewModel.start()
                if let initialTerm {
                    term = initialTerm
                    await viewModel.search(term: initialTerm)
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case let .idle(recents):
            recentsList(recents)
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case let .loaded(items):
            resultsList(items)
        case let .empty(query):
            emptyState(query)
        case let .failed(message):
            failedState(message)
        }
    }

    @ViewBuilder
    private func recentsList(_ recents: [String]) -> some View {
        if recents.isEmpty {
            ContentUnavailableView("최근 검색어 없음", systemImage: "magnifyingglass")
        } else {
            List {
                Section {
                    ForEach(recents, id: \.self) { recent in
                        Button {
                            term = recent
                            Task { await viewModel.selectRecent(recent) }
                        } label: {
                            Label(recent, systemImage: "clock.arrow.circlepath")
                        }
                        .foregroundStyle(.primary)
                    }
                } header: {
                    HStack {
                        Text("최근 검색")
                        Spacer()
                        Button("지우기") {
                            Task { await viewModel.clearRecents() }
                        }
                        .font(.footnote)
                    }
                }
            }
        }
    }

    private func resultsList(_ items: [SearchResultItem]) -> some View {
        List(items) { item in
            Button {
                onSelectApp(item.id)
            } label: {
                SearchResultRow(item: item, imageLoader: imageLoader)
            }
            .buttonStyle(.plain)
        }
        .listStyle(.plain)
    }

    private func emptyState(_ query: String) -> some View {
        ContentUnavailableView.search(text: query)
    }

    private func failedState(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("다시 시도") {
                Task { await viewModel.retry() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// 검색 결과 행. 아이콘·이름·부제·평점·가격 라벨을 표시한다.
private struct SearchResultRow: View {
    let item: SearchResultItem
    let imageLoader: ImageLoading

    var body: some View {
        HStack(spacing: 12) {
            AsyncImageView(url: item.iconURL, imageLoader: imageLoader)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.body)
                    .lineLimit(1)
                Text(item.genre.isEmpty ? item.sellerName : item.genre)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                if item.rating > 0 {
                    Text(String(format: "★ %.1f", item.rating))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(item.price ?? CommonStrings.Price.free)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tint)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
