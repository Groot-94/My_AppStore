//
//  AsyncImageView.swift
//  Search
//
//  Created by groot on 8/4/26.
//

import SwiftUI
import CoreKit

/// Core 의 `ImageLoading` 계약(캐시 우선)을 재사용하는 SwiftUI 이미지 뷰.
/// DesignSystem(UIKit) 에 의존하지 않고 자체 로딩 상태를 그린다.
struct AsyncImageView: View {
    let url: URL?
    let imageLoader: ImageLoading

    @State private var image: UIImage?
    @State private var isLoading = false

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color(uiColor: .secondarySystemBackground))
                    .overlay {
                        if isLoading {
                            ProgressView()
                        }
                    }
            }
        }
        .task(id: url) { await load() }
    }

    private func load() async {
        image = nil
        guard let url else { return }
        isLoading = true
        defer { isLoading = false }
        guard let data = try? await imageLoader.loadImageData(from: url),
              let loaded = UIImage(data: data) else { return }
        image = loaded
    }
}
