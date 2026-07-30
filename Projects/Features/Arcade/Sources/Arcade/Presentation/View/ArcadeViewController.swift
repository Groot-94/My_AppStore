//
//  ArcadeViewController.swift
//  Arcade
//
//  Created by groot on 7/29/26.
//

import UIKit
import DesignSystem
import CoreKit

/// Arcade 탭 화면(UIKit). 히어로 배너(정적) + 캐러셀 2섹션 + 구독 안내 배너(UI만).
final class ArcadeViewController: UIViewController {
    private let viewModel: ArcadeViewModel
    private let imageLoader: ImageLoading
    /// 게임 선택 → AppDetail push 훅. Builder 가 주입.
    var onSelectApp: (Int) -> Void = { _ in }

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let messageView = MessageStateView()

    private var subscription: ObservationSubscription?

    private let newGamesTitle = "새로 추가된 게임"
    private let popularTitle = "인기 아케이드 게임"

    init(viewModel: ArcadeViewModel, imageLoader: ImageLoading) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) unavailable") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "아케이드"
        view.backgroundColor = AppColors.background
        navigationController?.navigationBar.prefersLargeTitles = true
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
        contentStack.spacing = 28
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

    private func render(_ state: ArcadeViewModel.State) {
        switch state {
        case .loading:
            showOverlay(loadingIndicator)
            loadingIndicator.startAnimating()

        case let .loaded(feed):
            showOverlay(nil)
            rebuildSections(with: feed)

        case let .failed(message):
            showOverlay(messageView)
            messageView.configure(title: CommonStrings.Error.loadFailedTitle, message: message, actionTitle: "다시 시도")
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

    private func rebuildSections(with feed: ArcadeFeed) {
        for subview in contentStack.arrangedSubviews {
            contentStack.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }

        contentStack.addArrangedSubview(makeHeroBanner(feed.hero))

        if feed.isEmpty {
            contentStack.addArrangedSubview(makeEmptyNotice())
        } else {
            if !feed.newGames.isEmpty {
                contentStack.addArrangedSubview(makeCarousel(title: newGamesTitle, games: feed.newGames))
            }
            if !feed.popular.isEmpty {
                contentStack.addArrangedSubview(makeCarousel(title: popularTitle, games: feed.popular))
            }
        }

        contentStack.addArrangedSubview(makeSubscriptionBanner())
    }

    private func makeHeroBanner(_ hero: ArcadeHero) -> UIView {
        let banner = ArcadeBannerView(style: .hero)
        banner.configure(title: hero.title, subtitle: hero.subtitle)
        // 히어로 탭은 동작 없음(UI만).
        return wrapInMargins(banner)
    }

    private func makeSubscriptionBanner() -> UIView {
        let banner = ArcadeBannerView(style: .subscription)
        banner.configure(title: "구독하고 200개+ 게임을", subtitle: "광고 없이, 추가 결제 없이 즐겨보세요.")
        // 구독 배너 탭은 동작 없음(결제 Out of Scope).
        return wrapInMargins(banner)
    }

    private func makeEmptyNotice() -> UIView {
        let label = UILabel()
        label.text = "표시할 게임이 없습니다."
        label.font = AppFont.subheadline
        label.textColor = AppColors.secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return wrapInMargins(label)
    }

    private func makeCarousel(title: String, games: [ArcadeGame]) -> UIView {
        let header = makeHeader(title: title)

        let carousel = CarouselView()
        carousel.configure(
            items: games.map {
                CarouselView.Item(id: $0.id, imageURL: $0.artworkURL, title: $0.name, subtitle: $0.genre)
            },
            loader: imageLoader
        )
        carousel.onSelect = { [weak self] id in self?.onSelectApp(id) }
        carousel.translatesAutoresizingMaskIntoConstraints = false
        carousel.heightAnchor.constraint(equalToConstant: 240).isActive = true

        let section = UIStackView(arrangedSubviews: [header, carousel])
        section.axis = .vertical
        section.spacing = 8
        return section
    }

    // MARK: - Helpers

    private func makeHeader(title: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = AppFont.bold(.title2)
        titleLabel.textColor = AppColors.label
        return wrapInMargins(titleLabel)
    }

    private func wrapInMargins(_ content: UIView) -> UIView {
        let container = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: container.topAnchor),
            content.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
        ])
        return container
    }
}
