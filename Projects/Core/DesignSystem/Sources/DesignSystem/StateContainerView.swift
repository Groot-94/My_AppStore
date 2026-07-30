//
//  StateContainerView.swift
//  DesignSystem
//
//  Created by groot on 7/30/26.
//

import UIKit

/// 세로 스택 화면 컨테이너: 스크롤 + 세로 스택 + 로딩/메시지 상태 오버레이 전환을 흡수한다.
///
/// 콘텐츠 스택(`contentStack`)에 섹션 뷰를 직접 조립하고, `state` 로 로딩/콘텐츠/실패를
/// 전환한다. 섹션 구성·마진 등 화면 고유 레이아웃은 호스트가 스택에 채워 넣는다.
public final class StateContainerView: UIView {

    /// 화면 상태.
    public enum State {
        case loading
        case content
        /// 메시지 상태(제목 + 부제 + 선택적 액션 버튼).
        case message(title: String, message: String?, actionTitle: String?)
    }

    /// 섹션을 조립하는 세로 스택(호스트가 직접 채운다).
    public let contentStack = UIStackView()

    /// 메시지 상태 액션 버튼 탭 콜백.
    public var onMessageAction: (() -> Void)?

    private let scrollView = UIScrollView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let messageView = MessageStateView()

    /// - Parameters:
    ///   - layoutMargins: 콘텐츠 스택 마진.
    ///   - spacing: 콘텐츠 스택 항목 간격.
    public init(
        layoutMargins: UIEdgeInsets,
        spacing: CGFloat
    ) {
        super.init(frame: .zero)
        setup(layoutMargins: layoutMargins, spacing: spacing)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Pull-to-refresh 컨트롤 설치(설정 시에만).
    public func setRefreshControl(_ control: UIRefreshControl) {
        scrollView.refreshControl = control
    }

    private func setup(layoutMargins: UIEdgeInsets, spacing: CGFloat) {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = spacing
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = layoutMargins
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])

        for overlay in [loadingIndicator, messageView] as [UIView] {
            overlay.translatesAutoresizingMaskIntoConstraints = false
            overlay.isHidden = true
            addSubview(overlay)
            NSLayoutConstraint.activate([
                overlay.topAnchor.constraint(equalTo: topAnchor),
                overlay.leadingAnchor.constraint(equalTo: leadingAnchor),
                overlay.trailingAnchor.constraint(equalTo: trailingAnchor),
                overlay.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        }
        messageView.onAction = { [weak self] in self?.onMessageAction?() }
    }

    /// 콘텐츠 스택의 기존 섹션을 모두 제거한다.
    public func clearContent() {
        for subview in contentStack.arrangedSubviews {
            contentStack.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }

    public func apply(_ state: State) {
        switch state {
        case .loading:
            showLoading()
        case .content:
            showContent()
        case let .message(title, message, actionTitle):
            showMessage()
            messageView.configure(title: title, message: message, actionTitle: actionTitle)
        }
    }

    private func showLoading() {
        messageView.isHidden = true
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        scrollView.isHidden = true
    }

    private func showContent() {
        messageView.isHidden = true
        loadingIndicator.isHidden = true
        loadingIndicator.stopAnimating()
        scrollView.isHidden = false
    }

    private func showMessage() {
        messageView.isHidden = false
        loadingIndicator.isHidden = true
        loadingIndicator.stopAnimating()
        scrollView.isHidden = true
    }
}
