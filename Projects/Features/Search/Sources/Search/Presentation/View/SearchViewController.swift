//
//  SearchViewController.swift
//  Search
//
//  Created by groot on 7/29/26.
//

import UIKit
import DesignSystem
import CoreKit
import SearchInterface

/// 검색 화면(UIKit). `UISearchController` + 결과/최근검색어 테이블.
///
/// `SearchViewModel` 상태를 `ObservationSubscription` 으로 관찰해 렌더한다.
final class SearchViewController: UIViewController {
    private enum Section { case recents, results }

    private let viewModel: SearchViewModel
    private let imageLoader: ImageLoading
    /// 결과 행 탭 시 상향 이벤트를 방출하는 라우팅 delegate. App(Coordinator)이 소유.
    weak var router: SearchRouting?

    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let messageView = MessageStateView()

    /// 관찰 구독(강한 참조로 보유 — 해제 시 관찰 중단).
    private var subscription: ObservationSubscription?

    /// 현재 렌더 중인 섹션/데이터 스냅샷.
    private var displayedRecents: [String] = []
    private var displayedResults: [SearchResultItem] = []
    private var currentSection: Section = .recents

    init(viewModel: SearchViewModel, imageLoader: ImageLoading) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) unavailable") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "검색"
        view.backgroundColor = AppColors.background
        setupSearchController()
        setupTableView()
        setupOverlays()
        bind()
        Task { await viewModel.start() }
    }

    // MARK: - Setup

    private func setupSearchController() {
        searchController.searchResultsUpdater = nil
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "게임, 앱, 스토리 등"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = .clear
        tableView.register(AppRowCell.self, forCellReuseIdentifier: AppRowCell.reuseID)
        tableView.register(SearchRecentCell.self, forCellReuseIdentifier: SearchRecentCell.reuseID)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
            Task { await self.viewModel.retry() }
        }
    }

    // MARK: - Observation

    private func bind() {
        subscription = ObservationSubscription { [weak self] in
            guard let self else { return }
            self.render(self.viewModel.state)
        }
    }

    private func render(_ state: SearchViewModel.State) {
        switch state {
        case let .idle(recents):
            currentSection = .recents
            displayedRecents = recents
            displayedResults = []
            showOverlay(nil)
            tableView.isHidden = false
            tableView.reloadData()

        case .loading:
            showOverlay(loadingIndicator)
            loadingIndicator.startAnimating()

        case let .loaded(items):
            currentSection = .results
            displayedResults = items
            showOverlay(nil)
            tableView.isHidden = false
            tableView.reloadData()
            if !items.isEmpty {
                tableView.setContentOffset(.zero, animated: false)
            }

        case let .empty(term):
            showOverlay(messageView)
            messageView.configure(
                title: "'\(term)'에 대한 결과 없음",
                message: "다른 검색어로 시도해 보세요.",
                actionTitle: nil
            )

        case let .failed(message):
            showOverlay(messageView)
            messageView.configure(
                title: CommonStrings.Error.loadFailedTitle,
                message: message,
                actionTitle: "다시 시도"
            )
        }
    }

    /// 세 표시 상태(테이블/스피너/메시지) 중 하나만 노출.
    private func showOverlay(_ overlay: UIView?) {
        let isMessage = (overlay === messageView)
        let isLoading = (overlay === loadingIndicator)

        messageView.isHidden = !isMessage
        loadingIndicator.isHidden = !isLoading
        if !isLoading { loadingIndicator.stopAnimating() }
        // 로딩/메시지 중엔 테이블을 가린다.
        tableView.isHidden = isMessage || isLoading
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let term = searchBar.text ?? ""
        Task { await viewModel.search(term: term) }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        Task { await viewModel.cancelSearch() }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // 검색어를 전부 지우면 idle(최근 검색어)로 복귀.
        if searchText.isEmpty {
            Task { await viewModel.cancelSearch() }
        }
    }
}

// MARK: - UITableViewDataSource / Delegate

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentSection {
        case .recents: return displayedRecents.count
        case .results: return displayedResults.count
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        (currentSection == .recents && !displayedRecents.isEmpty) ? "최근 검색어" : nil
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard currentSection == .recents, !displayedRecents.isEmpty else { return nil }
        return makeRecentsHeader()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        (currentSection == .recents && !displayedRecents.isEmpty) ? 44 : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch currentSection {
        case .recents:
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchRecentCell.reuseID, for: indexPath)
            (cell as? SearchRecentCell)?.configure(term: displayedRecents[indexPath.row])
            return cell

        case .results:
            let cell = tableView.dequeueReusableCell(withIdentifier: AppRowCell.reuseID, for: indexPath)
            guard let rowCell = cell as? AppRowCell else { return cell }
            let item = displayedResults[indexPath.row]
            rowCell.configure(with: Self.model(for: item), loader: imageLoader)
            // 받기 버튼: UI 변화만(다운로드 없음).
            rowCell.onGetTapped = { [weak rowCell] in
                rowCell?.configure(with: Self.model(for: item, actionTitle: CommonStrings.Action.open), loader: nil)
            }
            return rowCell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch currentSection {
        case .recents:
            let term = displayedRecents[indexPath.row]
            searchController.searchBar.text = term
            searchController.isActive = true
            Task { await viewModel.selectRecent(term) }

        case .results:
            router?.searchDidSelectApp(id: displayedResults[indexPath.row].id)
        }
    }

    // MARK: Helpers

    private func makeRecentsHeader() -> UIView {
        let container = UIView()
        let title = UILabel()
        title.text = "최근 검색어"
        title.font = AppFont.bold(.title3)
        title.textColor = AppColors.label

        let clearButton = UIButton(type: .system)
        clearButton.setTitle("지우기", for: .normal)
        clearButton.titleLabel?.font = AppFont.subheadline
        clearButton.setTitleColor(AppColors.accent, for: .normal)
        clearButton.addAction(UIAction { [weak self] _ in Task { await self?.viewModel.clearRecents() } }, for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [title, UIView(), clearButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        return container
    }

    private static func model(
        for item: SearchResultItem,
        actionTitle: String? = nil
    ) -> AppRowCell.Model {
        AppRowCell.Model(
            iconURL: item.iconURL,
            title: item.name,
            subtitle: item.genre.isEmpty ? item.sellerName : item.genre,
            rating: item.rating > 0 ? item.rating : nil,
            ratingCount: item.ratingCount > 0 ? item.ratingCount : nil,
            actionTitle: actionTitle ?? item.price ?? CommonStrings.Price.free
        )
    }
}
