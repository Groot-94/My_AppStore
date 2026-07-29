//
//  AppIconView.swift
//  DesignSystem
//
//  Created by groot on 7/29/26.
//

import UIKit
import CoreKit

/// 앱 아이콘 뷰. `ImageLoading` 을 주입받아 URL 이미지를 비동기 로드한다.
public final class AppIconView: UIImageView {
    private var loader: ImageLoading?
    private var currentURL: URL?
    private var loadTask: Task<Void, Never>?

    /// - Parameter cornerRadius: 아이콘 둥근 정도(기본 12).
    public init(cornerRadius: CGFloat = 12) {
        super.init(frame: .zero)
        contentMode = .scaleAspectFill
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        layer.cornerCurve = .continuous
        layer.borderWidth = 1.0 / UIScreen.main.scale
        layer.borderColor = AppColors.separator.cgColor
        backgroundColor = AppColors.placeholder
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// 이미지 로더 주입(생성 직후 1회).
    public func configure(loader: ImageLoading) {
        self.loader = loader
    }

    /// URL 설정 → 비동기 로드. `nil` 이면 플레이스홀더 유지.
    public func setImage(url: URL?) {
        loadTask?.cancel()
        currentURL = url
        image = nil
        backgroundColor = AppColors.placeholder

        guard let url, let loader else { return }
        loadTask = Task { [weak self] in
            let data = try? await loader.loadImageData(from: url)
            guard !Task.isCancelled else { return }
            guard let self, self.currentURL == url, let data, let img = UIImage(data: data) else { return }
            await MainActor.run {
                self.image = img
                self.backgroundColor = .clear
            }
        }
    }

    public override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        layer.borderColor = AppColors.separator.cgColor
    }

    deinit { loadTask?.cancel() }
}
