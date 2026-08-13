//
//  TodayViewController.swift
//  Today
//
//  Created by groot on 7/29/26.
//

import UIKit
import DesignSystem
import CoreKit
import TodayInterface

/// Today 탭 화면(UIKit). 날짜 헤더 + 카드 세로 스크롤. Pull-to-refresh 지원.
final class TodayViewController: UIViewController {
    private let viewModel: TodayViewModel
    private let imageLoader: ImageLoading
    /// 앱 선택 시 상향 이벤트를 방출하는 라우팅 delegate. App(Coordinator)이 소유.
    weak var router: TodayRouting?

    private let container = StateContainerView(
        layoutMargins: UIEdgeInsets(top: 8, left: 16, bottom: 32, right: 16),
        spacing: 20
    )
    private let refreshControl = UIRefreshControl()

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
        setupContainer()
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

    private func setupContainer() {
        refreshControl.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            Task {
                await self.viewModel.refresh()
                self.refreshControl.endRefreshing()
            }
        }, for: .valueChanged)
        container.setRefreshControl(refreshControl)

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

    private func render(_ state: TodayViewModel.State) {
        switch state {
        case .loading:
            // refresh 중이면 기존 카드를 덮지 않고 refreshControl 스피너만 노출.
            if refreshControl.isRefreshing { return }
            container.apply(.loading)

        case let .loaded(cards):
            container.apply(.content)
            rebuildCards(cards)

        case let .failed(message):
            container.apply(.message(
                title: CommonStrings.Error.loadFailedTitle,
                message: message,
                actionTitle: "다시 시도"
            ))
        }
    }

    // MARK: - Cards

    private func rebuildCards(_ cards: [TodayCard]) {
        container.clearContent()

        container.contentStack.addArrangedSubview(makeDateHeader())

        for card in cards {
            let view: UIView
            switch card.kind {
            case .feature, .appOfTheDay:
                view = makeLargeCard(card)
            case .list:
                view = makeListCard(card)
            }
            container.contentStack.addArrangedSubview(view)
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
        cardView.onSelect = { [weak self] appID in self?.router?.todayDidSelectApp(id: appID) }
        return cardView
    }

    private func makeListCard(_ card: TodayCard) -> UIView {
        let cardView = TodayListCardView()
        cardView.configure(with: card, loader: imageLoader)
        cardView.onSelect = { [weak self] appID in self?.router?.todayDidSelectApp(id: appID) }
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
