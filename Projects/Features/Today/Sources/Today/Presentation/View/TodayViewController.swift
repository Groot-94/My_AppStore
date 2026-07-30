//
//  TodayViewController.swift
//  Today
//
//  Created by groot on 7/29/26.
//

import UIKit
import DesignSystem
import CoreKit

/// Today 탭 화면(UIKit). 날짜 헤더 + 카드 세로 스크롤. Pull-to-refresh 지원.
final class TodayViewController: UIViewController {
    private let viewModel: TodayViewModel
    private let imageLoader: ImageLoading
    /// 앱 선택 → AppDetail push 훅. Builder 가 주입.
    var onSelectApp: (Int) -> Void = { _ in }

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let refreshControl = UIRefreshControl()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let messageView = MessageStateView()

    private var subscription: ObservationSubscription?

    init(viewModel: TodayViewModel, imageLoader: ImageLoading) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) unavailable") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "투데이"
        view.backgroundColor = AppColors.background
        navigationController?.navigationBar.prefersLargeTitles = true
        setupNavigationBar()
        setupScrollView()
        setupOverlays()
        bind()
        Task { await viewModel.load() }
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        let profile = UIButton(type: .system)
        profile.setImage(UIImage(systemName: "person.crop.circle.fill"), for: .normal)
        profile.tintColor = AppColors.secondaryLabel
        // 프로필은 UI 만(동작 없음, Out of Scope).
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profile)
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        refreshControl.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            Task {
                await self.viewModel.refresh()
                self.refreshControl.endRefreshing()
            }
        }, for: .valueChanged)
        scrollView.refreshControl = refreshControl
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 32, right: 16)
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

    private func render(_ state: TodayViewModel.State) {
        switch state {
        case .loading:
            // refresh 중이면 기존 카드를 덮지 않고 refreshControl 스피너만 노출.
            if refreshControl.isRefreshing { return }
            showOverlay(loadingIndicator)
            loadingIndicator.startAnimating()

        case let .loaded(cards):
            showOverlay(nil)
            rebuildCards(cards)

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

    // MARK: - Cards

    private func rebuildCards(_ cards: [TodayCard]) {
        for subview in contentStack.arrangedSubviews {
            contentStack.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }

        contentStack.addArrangedSubview(makeDateHeader())

        for card in cards {
            let view: UIView
            switch card.kind {
            case .feature, .appOfTheDay:
                view = makeLargeCard(card)
            case .list:
                view = makeListCard(card)
            }
            contentStack.addArrangedSubview(view)
        }
    }

    private func makeDateHeader() -> UIView {
        let label = UILabel()
        label.text = Self.dateFormatter.string(from: Date()).uppercased()
        label.font = AppFont.bold(.subheadline)
        label.textColor = AppColors.secondaryLabel
        return label
    }

    private func makeLargeCard(_ card: TodayCard) -> UIView {
        let cardView = TodayLargeCardView()
        cardView.configure(with: card, loader: imageLoader)
        cardView.onSelect = { [weak self] appID in self?.onSelectApp(appID) }
        return cardView
    }

    private func makeListCard(_ card: TodayCard) -> UIView {
        let cardView = TodayListCardView()
        cardView.configure(with: card, loader: imageLoader)
        cardView.onSelect = { [weak self] appID in self?.onSelectApp(appID) }
        return cardView
    }

    /// "7월 29일 화요일" 형식(실제 오늘 날짜).
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter
    }()
}
