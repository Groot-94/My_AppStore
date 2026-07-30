//
//  SectionHeaderView.swift
//  DesignSystem
//
//  Created by groot on 7/30/26.
//

import UIKit

/// 섹션 헤더(제목 + 선택적 액션 버튼). 엔티티 비의존 — 원시 값 입력.
/// 세로 스택 화면에 직접 넣는 plain `UIView`.
public final class SectionHeaderView: UIView {

    private let titleLabel = UILabel()
    private let actionButton = UIButton(type: .system)

    /// 액션 버튼 탭 콜백(설정 시에만 버튼 표시).
    public var onAction: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        titleLabel.font = AppFont.bold(.title2)
        titleLabel.textColor = AppColors.label

        actionButton.titleLabel?.font = AppFont.subheadline
        actionButton.setTitleColor(AppColors.accent, for: .normal)
        actionButton.setContentHuggingPriority(.required, for: .horizontal)
        actionButton.addAction(UIAction { [weak self] _ in self?.onAction?() }, for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titleLabel, UIView(), actionButton])
        stack.axis = .horizontal
        stack.alignment = .firstBaseline
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    /// - Parameters:
    ///   - title: 섹션 제목.
    ///   - actionTitle: 액션 버튼 문구(nil 이면 버튼 숨김 — 예: "모두 보기").
    public func configure(title: String, actionTitle: String? = nil) {
        titleLabel.text = title
        if let actionTitle {
            actionButton.isHidden = false
            actionButton.setTitle(actionTitle, for: .normal)
        } else {
            actionButton.isHidden = true
        }
    }
}
