//
//  AppDetailViewController.swift
//  AppDetail
//
//  Created by groot on 7/29/26.
//

import UIKit
import DesignSystem
import CoreKit

/// 앱 상세 화면(UIKit).
///
/// 책임은 두 가지뿐이다 — `AppDetailViewModel` 상태를 관찰해 렌더하고, 섹션 뷰를 순서대로 조립한다.
/// 각 섹션의 조판은 `AppDetail*View` 들이 소유한다.
final class AppDetailViewController: UIViewController {
    private let viewModel: AppDetailViewModel
    private let imageLoader: ImageLoading

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let messageView = MessageStateView()

    private var subscription: ObservationSubscription?

    init(viewModel: AppDetailViewModel, imageLoader: ImageLoading) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) unavailable") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        navigationItem.largeTitleDisplayMode = .never
        setupScrollView()
        setupOverlays()
        bind()
        Task { await viewModel.load() }
    }

    // MARK: - Setup

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(top: 16, left: 0, bottom: 32, right: 0)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])
    }

    private func setupOverlays() {
        for overlay in [loadingIndicator, messageView] as [UIView] {
            overlay.translatesAutoresizingMaskIntoConstraints = false
            overlay.isHidden = true
            view.addSubview(overlay)
            NSLayoutConstraint.activate([
                overlay.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        }
        messageView.onAction = { [weak self] in
            guard let self else { return }
            Task { await self.viewModel.load() }
        }
    }

    // MARK: - Observation

    private func bind() {
        subscription = ObservationSubscription { [weak self] in
            guard let self else { return }
            self.render(self.viewModel.state)
        }
    }

    private func render(_ state: AppDetailViewModel.State) {
        switch state {
        case .loading:
            showOverlay(loadingIndicator)
            loadingIndicator.startAnimating()

        case let .loaded(model):
            showOverlay(nil)
            title = model.name
            rebuildSections(with: model)

        case let .failed(message, retryable):
            showOverlay(messageView)
            messageView.configure(
                title: retryable ? CommonStrings.Error.loadFailedTitle : "앱을 찾을 수 없음",
                message: message,
                actionTitle: retryable ? "다시 시도" : nil
            )
        }
    }

    private func showOverlay(_ overlay: UIView?) {
        let isMessage = (overlay === messageView)
        let isLoading = (overlay === loadingIndicator)
        messageView.isHidden = !isMessage
        loadingIndicator.isHidden = !isLoading
        if !isLoading { loadingIndicator.stopAnimating() }
        scrollView.isHidden = isMessage || isLoading
    }

    // MARK: - Sections

    /// 섹션 뷰를 순서대로 쌓는다. 값이 없는 섹션(스크린샷·설명·릴리즈 노트)은 건너뛴다.
    private func rebuildSections(with model: AppDetailPresentation) {
        for subview in contentStack.arrangedSubviews {
            contentStack.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }

        contentStack.addArrangedSubview(
            AppDetailSection.wrapInMargins(
                AppDetailHeaderView(
                    name: model.name,
                    sellerName: model.sellerName,
                    iconURL: model.iconURL,
                    priceText: model.priceText,
                    imageLoader: imageLoader
                )
            )
        )
        contentStack.addArrangedSubview(AppDetailMetaStripView(cells: model.metaCells))

        if !model.screenshotURLs.isEmpty {
            contentStack.addArrangedSubview(
                AppDetailScreenshotsView(urls: model.screenshotURLs, imageLoader: imageLoader)
            )
        }
        if !model.description.isEmpty {
            contentStack.addArrangedSubview(AppDetailDescriptionView(text: model.description))
        }
        if let notes = model.releaseNotes {
            contentStack.addArrangedSubview(
                AppDetailReleaseNotesView(versionLine: model.versionLine, notes: notes)
            )
        }
        contentStack.addArrangedSubview(AppDetailInfoTableView(rows: model.infoRows))
    }
}
