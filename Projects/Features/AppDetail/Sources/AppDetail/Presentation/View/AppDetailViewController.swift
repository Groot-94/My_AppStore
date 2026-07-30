//
//  AppDetailViewController.swift
//  AppDetail
//
//  Created by groot on 7/29/26.
//

import UIKit
import DesignSystem
import CoreKit

/// 앱 상세 화면(UIKit). 세로 스크롤 컨테이너에 섹션을 조립한다.
///
/// `AppDetailViewModel` 상태를 `ObservationSubscription` 으로 관찰해 렌더한다.
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
        setupNavigationBar()
        setupScrollView()
        setupOverlays()
        bind()
        Task { await viewModel.load() }
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
    }

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

    private func rebuildSections(with model: AppDetailPresentation) {
        for subview in contentStack.arrangedSubviews {
            contentStack.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }

        contentStack.addArrangedSubview(makeHeader(model))
        contentStack.addArrangedSubview(makeMetaStrip(model))

        if !model.screenshotURLs.isEmpty {
            contentStack.addArrangedSubview(makeScreenshots(model.screenshotURLs))
        }
        if !model.description.isEmpty {
            contentStack.addArrangedSubview(makeDescription(model.description))
        }
        if let notes = model.releaseNotes {
            contentStack.addArrangedSubview(makeReleaseNotes(version: model.versionLine, notes: notes))
        }
        contentStack.addArrangedSubview(makeInfoTable(model))
    }

    private func makeHeader(_ model: AppDetailPresentation) -> UIView {
        let icon = AppIconView(cornerRadius: 20)
        icon.setImage(url: model.iconURL, loader: imageLoader)
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 96),
            icon.heightAnchor.constraint(equalToConstant: 96),
        ])

        let nameLabel = UILabel()
        nameLabel.text = model.name
        nameLabel.font = AppFont.bold(.title2)
        nameLabel.textColor = AppColors.label
        nameLabel.numberOfLines = 2

        let sellerLabel = UILabel()
        sellerLabel.text = model.sellerName
        sellerLabel.font = AppFont.subheadline
        sellerLabel.textColor = AppColors.secondaryLabel
        sellerLabel.numberOfLines = 1

        let getButton = GetButton()
        getButton.configure(title: model.priceText)
        getButton.onTap = { [weak getButton] in getButton?.configure(title: CommonStrings.Action.open) }

        let menuButton = UIButton(type: .system)
        menuButton.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        menuButton.tintColor = AppColors.accent
        menuButton.setContentHuggingPriority(.required, for: .horizontal)

        let actionRow = UIStackView(arrangedSubviews: [getButton, UIView(), menuButton])
        actionRow.axis = .horizontal
        actionRow.alignment = .center
        actionRow.spacing = 12

        let textColumn = UIStackView(arrangedSubviews: [nameLabel, sellerLabel, actionRow])
        textColumn.axis = .vertical
        textColumn.spacing = 6
        textColumn.setCustomSpacing(12, after: sellerLabel)

        let row = UIStackView(arrangedSubviews: [icon, textColumn])
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = 16
        return wrapInMargins(row)
    }

    private func makeMetaStrip(_ model: AppDetailPresentation) -> UIView {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let cells = model.metaCells
        for (index, cell) in cells.enumerated() {
            stack.addArrangedSubview(makeMetaCell(caption: cell.caption, value: cell.value))
            if index < cells.count - 1 {
                stack.addArrangedSubview(makeMetaDivider())
            }
        }

        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            stack.heightAnchor.constraint(equalTo: scroll.frameLayoutGuide.heightAnchor),
            scroll.heightAnchor.constraint(equalToConstant: 56),
        ])
        return scroll
    }

    private func makeMetaCell(caption: String, value: String) -> UIView {
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = AppFont.bold(.subheadline)
        valueLabel.textColor = AppColors.secondaryLabel
        valueLabel.textAlignment = .center

        let captionLabel = UILabel()
        captionLabel.text = caption
        captionLabel.font = AppFont.caption
        captionLabel.textColor = AppColors.tertiaryLabel
        captionLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [valueLabel, captionLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return stack
    }

    private func makeMetaDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = AppColors.separator
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.widthAnchor.constraint(equalToConstant: 1.0 / max(UIScreen.main.scale, 1)).isActive = true
        divider.heightAnchor.constraint(equalToConstant: 32).isActive = true
        return divider
    }

    private func makeScreenshots(_ urls: [URL]) -> UIView {
        let pager = ScreenshotPager()
        pager.configure(urls: urls, loader: imageLoader)
        pager.translatesAutoresizingMaskIntoConstraints = false
        pager.heightAnchor.constraint(equalToConstant: 440).isActive = true

        let section = UIStackView(arrangedSubviews: [sectionTitle("미리 보기"), pager])
        section.axis = .vertical
        section.spacing = 12
        return section
    }

    private func makeDescription(_ text: String) -> UIView {
        let title = wrapInMargins(sectionTitle("설명"))

        let bodyLabel = UILabel()
        bodyLabel.text = text
        bodyLabel.font = AppFont.body
        bodyLabel.textColor = AppColors.label
        bodyLabel.numberOfLines = 4

        let moreButton = UIButton(type: .system)
        moreButton.setTitle("더 보기", for: .normal)
        moreButton.titleLabel?.font = AppFont.bold(.subheadline)
        moreButton.setTitleColor(AppColors.accent, for: .normal)
        moreButton.contentHorizontalAlignment = .trailing
        moreButton.addAction(UIAction { [weak bodyLabel, weak moreButton] _ in
            bodyLabel?.numberOfLines = 0
            moreButton?.isHidden = true
            bodyLabel?.superview?.superview?.layoutIfNeeded()
        }, for: .touchUpInside)

        let column = UIStackView(arrangedSubviews: [bodyLabel, moreButton])
        column.axis = .vertical
        column.spacing = 8
        column.alignment = .fill

        let section = UIStackView(arrangedSubviews: [title, wrapInMargins(column)])
        section.axis = .vertical
        section.spacing = 8
        return section
    }

    private func makeReleaseNotes(version: String, notes: String) -> UIView {
        let versionLabel = UILabel()
        versionLabel.text = version
        versionLabel.font = AppFont.subheadline
        versionLabel.textColor = AppColors.secondaryLabel

        let notesLabel = UILabel()
        notesLabel.text = notes
        notesLabel.font = AppFont.body
        notesLabel.textColor = AppColors.label
        notesLabel.numberOfLines = 0

        let column = UIStackView(arrangedSubviews: [versionLabel, notesLabel])
        column.axis = .vertical
        column.spacing = 8

        let section = UIStackView(arrangedSubviews: [sectionTitle("새로운 기능"), column])
        section.axis = .vertical
        section.spacing = 8
        return wrapInMargins(section)
    }

    private func makeInfoTable(_ model: AppDetailPresentation) -> UIView {
        let rows = model.infoRows.map { makeInfoRow(title: $0.title, value: $0.value) }
        let column = UIStackView(arrangedSubviews: [sectionTitle("정보")] + rows)
        column.axis = .vertical
        column.spacing = 12
        return wrapInMargins(column)
    }

    private func makeInfoRow(title: String, value: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = AppFont.body
        titleLabel.textColor = AppColors.secondaryLabel
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = AppFont.body
        valueLabel.textColor = AppColors.label
        valueLabel.textAlignment = .right
        valueLabel.numberOfLines = 0

        let row = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        row.axis = .horizontal
        row.alignment = .firstBaseline
        row.spacing = 16
        return row
    }

    // MARK: - Helpers

    private func sectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = AppFont.bold(.title3)
        label.textColor = AppColors.label
        return label
    }

    /// 좌우 16pt 여백을 적용해 감싼다(가로 스크롤 섹션은 자체 인셋 사용).
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
