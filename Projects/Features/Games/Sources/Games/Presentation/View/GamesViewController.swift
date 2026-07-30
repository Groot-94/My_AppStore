//
//  GamesViewController.swift
//  Games
//
//  Created by groot on 7/29/26.
//

import UIKit
import DesignSystem
import CoreKit
import SeeAllInterface

/// Games 탭 화면(UIKit). Apps 와 동형 — 세로 스크롤에 추천/게임 차트/하위 카테고리 섹션 조립.
/// SeeAll 입력의 genreID 는 6014(게임)로 전달한다.
final class GamesViewController: UIViewController {
    private let viewModel: GamesViewModel
    private let imageLoader: ImageLoading
    var onSelectApp: (Int) -> Void = { _ in }
    var onSeeAll: (SeeAllInput) -> Void = { _ in }

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let messageView = MessageStateView()

    private var subscription: ObservationSubscription?

    private let gamesGenreID = 6014
    private let featuredSectionTitle = "추천 게임"
    private let topFreeTitle = "인기 무료 게임"
    private let topPaidTitle = "인기 유료 게임"
    private let categoriesTitle = "카테고리"

    init(viewModel: GamesViewModel, imageLoader: ImageLoading) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) unavailable") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "게임"
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

    private func render(_ state: GamesViewModel.State) {
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

    private func rebuildSections(with feed: GamesFeed) {
        for subview in contentStack.arrangedSubviews {
            contentStack.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }

        if !feed.featured.isEmpty {
            contentStack.addArrangedSubview(makeCarousel(feed.featured))
        }
        if !feed.topFree.isEmpty {
            contentStack.addArrangedSubview(
                makeChartSection(title: topFreeTitle, items: feed.topFree, feed: .topFree)
            )
        }
        if !feed.topPaid.isEmpty {
            contentStack.addArrangedSubview(
                makeChartSection(title: topPaidTitle, items: feed.topPaid, feed: .topPaid)
            )
        }
        if !feed.categories.isEmpty {
            contentStack.addArrangedSubview(makeCategorySection(feed.categories))
        }
    }

    private func makeCarousel(_ featured: [FeaturedApp]) -> UIView {
        let header = makeHeader(title: featuredSectionTitle, seeAll: nil)

        let carousel = CarouselView()
        carousel.configure(
            items: featured.map {
                CarouselView.Item(id: $0.id, imageURL: $0.artworkURL, title: $0.name, subtitle: $0.tagline)
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

    private func makeChartSection(title: String, items: [ChartItem], feed: ChartFeedKind) -> UIView {
        let input = SeeAllInput(title: title, feed: feed, genreID: gamesGenreID)
        let header = makeHeader(title: title, seeAll: { [weak self] in self?.onSeeAll(input) })

        let rows = UIStackView()
        rows.axis = .vertical
        rows.spacing = 0
        for item in items.prefix(3) {
            rows.addArrangedSubview(makeChartRow(item))
        }

        let section = UIStackView(arrangedSubviews: [header, rows])
        section.axis = .vertical
        section.spacing = 8
        return section
    }

    private func makeChartRow(_ item: ChartItem) -> UIView {
        let row = ChartRankRow(frame: .zero)
        row.configure(with: model(for: item), loader: imageLoader)
        row.onGetTapped = { [weak row, weak self] in
            guard let row, let self else { return }
            row.configure(with: self.model(for: item, actionTitle: CommonStrings.Action.open), loader: nil)
        }
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 68).isActive = true

        let tap = ChartRowTapGesture(target: self, action: #selector(chartRowTapped))
        tap.appID = item.id
        tap.delegate = self
        row.addGestureRecognizer(tap)
        return row
    }

    @objc
    private func chartRowTapped(_ gesture: ChartRowTapGesture) {
        onSelectApp(gesture.appID)
    }

    private func makeCategorySection(_ categories: [Category]) -> UIView {
        let header = makeHeader(title: categoriesTitle, seeAll: nil)

        let grid = CategoryGridView()
        grid.configure(items: categories.map {
            CategoryGridView.Item(id: $0.genreID, title: $0.name, symbolName: $0.symbol)
        })
        // 하위 카테고리 탭은 v1 범위 밖(동작 없음).

        let section = UIStackView(arrangedSubviews: [header, grid])
        section.axis = .vertical
        section.spacing = 8
        return section
    }

    // MARK: - Helpers

    private func makeHeader(title: String, seeAll: (() -> Void)?) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = AppFont.bold(.title2)
        titleLabel.textColor = AppColors.label

        let stack: UIStackView
        if let seeAll {
            let button = UIButton(type: .system)
            button.setTitle("모두 보기", for: .normal)
            button.titleLabel?.font = AppFont.subheadline
            button.setTitleColor(AppColors.accent, for: .normal)
            button.addAction(UIAction { _ in seeAll() }, for: .touchUpInside)
            button.setContentHuggingPriority(.required, for: .horizontal)
            stack = UIStackView(arrangedSubviews: [titleLabel, UIView(), button])
        } else {
            stack = UIStackView(arrangedSubviews: [titleLabel])
        }
        stack.axis = .horizontal
        stack.alignment = .firstBaseline
        return wrapInMargins(stack)
    }

    private func model(for item: ChartItem, actionTitle: String? = "받기") -> ChartRankRow.Model {
        ChartRankRow.Model(
            rank: item.rank,
            iconURL: item.artworkURL,
            title: item.name,
            subtitle: item.genre.isEmpty ? item.artistName : "\(item.artistName) · \(item.genre)",
            actionTitle: actionTitle
        )
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

// MARK: - UIGestureRecognizerDelegate

extension GamesViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        !(touch.view is UIControl)
    }
}

/// appID 를 실어 나르는 셀 탭 제스처.
final class ChartRowTapGesture: UITapGestureRecognizer {
    var appID = 0
}
