//
//  SeeAllViewController.swift
//  SeeAll
//
//  Created by groot on 7/29/26.
//

import UIKit
import DesignSystem
import CoreKit

/// 차트 전체 목록 화면(UIKit). `ChartRankRow` 목록 + 로딩/실패/빈 상태 오버레이.
final class SeeAllViewController: UIViewController {
    private let viewModel: SeeAllViewModel
    private let imageLoader: ImageLoading
    /// 행 탭 시 상위(Builder)로 위임하는 네비게이션 훅.
    var onSelectApp: (Int) -> Void = { _ in }

    private lazy var collectionView = makeCollectionView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let messageView = MessageStateView()

    private var subscription: ObservationSubscription?
    private var items: [SeeAllItem] = []

    init(viewModel: SeeAllViewModel, imageLoader: ImageLoading) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) unavailable") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.input.title
        view.backgroundColor = AppColors.background
        navigationItem.largeTitleDisplayMode = .never
        setupCollectionView()
        setupOverlays()
        bind()
        Task { await viewModel.load() }
    }

    // MARK: - Setup

    private func makeCollectionView() -> UICollectionView {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.backgroundColor = .clear
        config.showsSeparators = true
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ChartRankRow.self, forCellWithReuseIdentifier: ChartRankRow.reuseID)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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

    private func render(_ state: SeeAllViewModel.State) {
        switch state {
        case .loading:
            showOverlay(loadingIndicator)
            loadingIndicator.startAnimating()

        case let .loaded(items) where items.isEmpty:
            showOverlay(messageView)
            messageView.configure(
                title: "표시할 항목이 없습니다",
                message: "이 카테고리의 차트 항목을 찾지 못했습니다.",
                actionTitle: nil
            )

        case let .loaded(items):
            self.items = items
            showOverlay(nil)
            collectionView.reloadData()

        case let .failed(message):
            showOverlay(messageView)
            messageView.configure(title: "불러올 수 없음", message: message, actionTitle: "다시 시도")
        }
    }

    private func showOverlay(_ overlay: UIView?) {
        let isMessage = (overlay === messageView)
        let isLoading = (overlay === loadingIndicator)
        messageView.isHidden = !isMessage
        loadingIndicator.isHidden = !isLoading
        if !isLoading { loadingIndicator.stopAnimating() }
        collectionView.isHidden = isMessage || isLoading
    }

    private func model(for item: SeeAllItem, actionTitle: String? = "받기") -> ChartRankRow.Model {
        ChartRankRow.Model(
            rank: item.rank,
            iconURL: item.artworkURL,
            title: item.name,
            subtitle: item.genre.isEmpty ? item.artistName : "\(item.artistName) · \(item.genre)",
            actionTitle: actionTitle
        )
    }
}

// MARK: - UICollectionViewDataSource / Delegate

extension SeeAllViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChartRankRow.reuseID, for: indexPath)
        guard let row = cell as? ChartRankRow else { return cell }
        let item = items[indexPath.item]
        row.configure(with: model(for: item), loader: imageLoader)
        row.onGetTapped = { [weak self, weak row] in
            guard let self, let row else { return }
            row.configure(with: self.model(for: item, actionTitle: "열기"), loader: nil)
        }
        return row
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        onSelectApp(items[indexPath.item].id)
    }
}
