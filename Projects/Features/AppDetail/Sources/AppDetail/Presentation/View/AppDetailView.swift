//
//  AppDetailView.swift
//  AppDetail
//
//  Created by groot on 8/4/26.
//

import SwiftUI
import CoreKit

/// 앱 상세 SwiftUI 뷰. UIKit `AppDetailViewController` 와 동일한 `AppDetailViewModel` 을 재사용한다.
public struct AppDetailView: View {
    @State private var viewModel: AppDetailViewModel
    private let imageLoader: ImageLoading

    public init(viewModel: AppDetailViewModel, imageLoader: ImageLoading) {
        _viewModel = State(wrappedValue: viewModel)
        self.imageLoader = imageLoader
    }

    public var body: some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case let .loaded(presentation):
            loaded(presentation)
        case let .failed(message, retryable):
            failed(message: message, retryable: retryable)
        }
    }

    private func loaded(_ presentation: AppDetailPresentation) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header(presentation)
                metaStrip(presentation.metaCells)
                if !presentation.screenshotURLs.isEmpty {
                    screenshots(presentation.screenshotURLs)
                }
                description(presentation)
                infoTable(presentation.infoRows)
            }
            .padding()
        }
    }

    private func header(_ presentation: AppDetailPresentation) -> some View {
        HStack(spacing: 16) {
            AsyncImageView(url: presentation.iconURL, imageLoader: imageLoader)
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(presentation.name)
                    .font(.title3.weight(.semibold))
                    .lineLimit(2)
                Text(presentation.sellerName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                HStack {
                    Text(presentation.priceText)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(.tint))
                    Spacer()
                }
            }
        }
    }

    private func metaStrip(_ cells: [AppDetailPresentation.MetaCell]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(cells.enumerated()), id: \.offset) { index, cell in
                    VStack(spacing: 4) {
                        Text(cell.caption)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(cell.value)
                            .font(.subheadline.weight(.semibold))
                    }
                    .frame(width: 90)
                    if index < cells.count - 1 {
                        Divider().frame(height: 34)
                    }
                }
            }
        }
    }

    private func screenshots(_ urls: [URL]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(urls, id: \.self) { url in
                    AsyncImageView(url: url, imageLoader: imageLoader)
                        .frame(width: 220, height: 460)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
        }
    }

    private func description(_ presentation: AppDetailPresentation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(presentation.versionLine)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(presentation.description)
                .font(.body)
        }
    }

    private func infoTable(_ rows: [AppDetailPresentation.InfoRow]) -> some View {
        VStack(spacing: 0) {
            Text("정보")
                .font(.title3.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                HStack {
                    Text(row.title)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(row.value)
                        .multilineTextAlignment(.trailing)
                }
                .font(.subheadline)
                .padding(.vertical, 10)
                if index < rows.count - 1 {
                    Divider()
                }
            }
        }
    }

    private func failed(message: String, retryable: Bool) -> some View {
        VStack(spacing: 16) {
            Image(systemName: retryable ? "wifi.slash" : "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            if retryable {
                Button("다시 시도") {
                    Task { await viewModel.load() }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
