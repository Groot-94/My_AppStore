//
//  TodayListCardView.swift
//  Today
//
//  Created by groot on 7/29/26.
//

import UIKit
import DesignSystem
import CoreKit

/// 리스트형 카드(피처 소유 뷰). 헤더 카피 + 참조 앱 행 여러 개.
final class TodayListCardView: UIView {
    /// 앱 행 선택 콜백(appID 전달).
    var onSelect: ((Int) -> Void)?

    private let eyebrowLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let rowsStack = UIStackView()

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        backgroundColor = AppColors.secondaryBackground
        layer.cornerRadius = 18
        layer.cornerCurve = .continuous

        eyebrowLabel.font = AppFont.bold(.caption1)
        eyebrowLabel.textColor = AppColors.accent

        titleLabel.font = AppFont.bold(.title2)
        titleLabel.textColor = AppColors.label
        titleLabel.numberOfLines = 2

        subtitleLabel.font = AppFont.subheadline
        subtitleLabel.textColor = AppColors.secondaryLabel
        subtitleLabel.numberOfLines = 2

        let textStack = UIStackView(arrangedSubviews: [eyebrowLabel, titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.setCustomSpacing(8, after: titleLabel)

        rowsStack.axis = .vertical
        rowsStack.spacing = 16

        let stack = UIStackView(arrangedSubviews: [textStack, rowsStack])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
    }

    func configure(with card: TodayCard, loader: ImageLoading) {
        eyebrowLabel.text = card.eyebrow.uppercased()
        titleLabel.text = card.title
        subtitleLabel.text = card.subtitle

        for subview in rowsStack.arrangedSubviews {
            rowsStack.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        for app in card.apps {
            let row = TodayAppRowView()
            row.configure(with: app, loader: loader)
            row.onSelect = { [weak self] id in self?.onSelect?(id) }
            rowsStack.addArrangedSubview(row)
        }
    }
}
