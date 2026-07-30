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

    private let container = StateContainerView(
        layoutMargins: UIEdgeInsets(top: 16, left: 0, bottom: 32, right: 0),
        spacing: 28
    )

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
        setupContainer()
        bind()
        Task { await viewModel.load() }
    }

    // MARK: - Setup

    private func setupContainer() {
        container.translatesAutoresizingMaskIntoConstraints = false
        container.onMessageAction = { [weak self] in
            guard let self else { return }
            Task { await self.viewModel.load() }
        }
        view.addSubview(container)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
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
            container.apply(.loading)

        case let .loaded(feed):
            container.apply(.content)
            rebuildSections(with: feed)

        case let .failed(message):
            container.apply(.message(
                title: CommonStrings.Error.loadFailedTitle,
                message: message,
                actionTitle: "다시 시도"
            ))
        }
    }

    // MARK: - Sections

    private func rebuildSections(with feed: ArcadeFeed) {
        container.clearContent()

        container.contentStack.addArrangedSubview(makeHeroBanner(feed.hero))

        if feed.isEmpty {
            container.contentStack.addArrangedSubview(makeEmptyNotice())
        } else {
            if !feed.newGames.isEmpty {
                container.contentStack.addArrangedSubview(makeCarousel(title: newGamesTitle, games: feed.newGames))
            }
            if !feed.popular.isEmpty {
                container.contentStack.addArrangedSubview(makeCarousel(title: popularTitle, games: feed.popular))
            }
        }

        container.contentStack.addArrangedSubview(makeSubscriptionBanner())
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
        let header = SectionHeaderView()
        header.configure(title: title)
        return wrapInMargins(header)
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
