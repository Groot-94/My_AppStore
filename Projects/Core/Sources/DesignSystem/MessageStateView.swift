//
//  MessageStateView.swift
//  DesignSystem
//
//  Created by groot on 7/29/26.
//

import UIKit

/// 빈 결과/실패 등 전체 화면 안내 상태 뷰(제목 + 부제 + 선택적 액션 버튼).
public final class MessageStateView: UIView {
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    private let stack = UIStackView()

    /// 액션 버튼 탭 콜백(설정 시에만 버튼 표시).
    public var onAction: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        titleLabel.font = AppFont.bold(.title3)
        titleLabel.textColor = AppColors.label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        messageLabel.font = AppFont.subheadline
        messageLabel.textColor = AppColors.secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        actionButton.addAction(UIAction { [weak self] _ in self?.onAction?() }, for: .touchUpInside)

        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(messageLabel)
        stack.setCustomSpacing(20, after: messageLabel)
        stack.addArrangedSubview(actionButton)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -32),
        ])
    }

    /// - Parameters:
    ///   - title: 큰 안내 문구.
    ///   - message: 보조 문구(nil 이면 숨김).
    ///   - actionTitle: 액션 버튼 문구(nil 이면 버튼 숨김 — 예: 빈 결과엔 버튼 없음).
    public func configure(title: String, message: String?, actionTitle: String?) {
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.isHidden = (message == nil)
        if let actionTitle {
            actionButton.isHidden = false
            actionButton.setTitle(actionTitle, for: .normal)
        } else {
            actionButton.isHidden = true
        }
    }
}
