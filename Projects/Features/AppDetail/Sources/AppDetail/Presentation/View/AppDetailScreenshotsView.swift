//
//  AppDetailScreenshotsView.swift
//  AppDetail
//
//  Created by groot on 8/9/26.
//

import UIKit
import DesignSystem
import CoreKit

/// 미리 보기 섹션(제목 + 스크린샷 가로 페이저).
final class AppDetailScreenshotsView: UIView {

    private static let pagerHeight: CGFloat = 440

    init(urls: [URL], imageLoader: ImageLoading) {
        super.init(frame: .zero)
        setup(urls: urls, imageLoader: imageLoader)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup(urls: [URL], imageLoader: ImageLoading) {
        let pager = ScreenshotPager()
        pager.configure(urls: urls, loader: imageLoader)
        pager.translatesAutoresizingMaskIntoConstraints = false
        pager.heightAnchor.constraint(equalToConstant: Self.pagerHeight).isActive = true

        let section = UIStackView(arrangedSubviews: [AppDetailSection.title("미리 보기"), pager])
        section.axis = .vertical
        section.spacing = 12
        section.translatesAutoresizingMaskIntoConstraints = false
        addSubview(section)
        NSLayoutConstraint.activate([
            section.topAnchor.constraint(equalTo: topAnchor),
            section.bottomAnchor.constraint(equalTo: bottomAnchor),
            section.leadingAnchor.constraint(equalTo: leadingAnchor),
            section.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}
