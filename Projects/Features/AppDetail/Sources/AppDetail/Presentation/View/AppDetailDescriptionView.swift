//
//  AppDetailDescriptionView.swift
//  AppDetail
//
//  Created by groot on 8/9/26.
//

import UIKit
import DesignSystem

/// 설명 섹션. 기본 4줄로 접어 두고 [더 보기] 로 펼친다.
final class AppDetailDescriptionView: UIView {

    private let bodyLabel = UILabel()
    private let moreButton = UIButton(type: .system)

    init(text: String) {
        super.init(frame: .zero)
        setup(text: text)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup(text: String) {
        bodyLabel.text = text
        bodyLabel.font = AppFont.body
        bodyLabel.textColor = AppColors.label
        bodyLabel.numberOfLines = 4

        moreButton.setTitle("더 보기", for: .normal)
        moreButton.titleLabel?.font = AppFont.bold(.subheadline)
        moreButton.setTitleColor(AppColors.accent, for: .normal)
        moreButton.contentHorizontalAlignment = .trailing
        moreButton.addAction(UIAction { [weak self] _ in self?.expand() }, for: .touchUpInside)

        let column = UIStackView(arrangedSubviews: [bodyLabel, moreButton])
        column.axis = .vertical
        column.spacing = 8
        column.alignment = .fill

        let section = UIStackView(arrangedSubviews: [
            AppDetailSection.wrapInMargins(AppDetailSection.title("설명")),
            AppDetailSection.wrapInMargins(column),
        ])
        section.axis = .vertical
        section.spacing = 8
        section.translatesAutoresizingMaskIntoConstraints = false
        addSubview(section)
        NSLayoutConstraint.activate([
            section.topAnchor.constraint(equalTo: topAnchor),
            section.bottomAnchor.constraint(equalTo: bottomAnchor),
            section.leadingAnchor.constraint(equalTo: leadingAnchor),
            section.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    private func expand() {
        bodyLabel.numberOfLines = 0
        moreButton.isHidden = true
        superview?.layoutIfNeeded()
    }
}
