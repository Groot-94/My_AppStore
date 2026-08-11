//
//  AppDetailInfoTableView.swift
//  AppDetail
//
//  Created by groot on 8/9/26.
//

import UIKit
import DesignSystem

/// 정보 섹션(크기·카테고리·호환성 등 제목/값 행 목록).
final class AppDetailInfoTableView: UIView {

    init(rows: [AppDetailPresentation.InfoRow]) {
        super.init(frame: .zero)
        setup(rows: rows)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup(rows: [AppDetailPresentation.InfoRow]) {
        let rowViews = rows.map { makeRow(title: $0.title, value: $0.value) }
        let column = UIStackView(arrangedSubviews: [AppDetailSection.title("정보")] + rowViews)
        column.axis = .vertical
        column.spacing = 12

        let wrapped = AppDetailSection.wrapInMargins(column)
        wrapped.translatesAutoresizingMaskIntoConstraints = false
        addSubview(wrapped)
        NSLayoutConstraint.activate([
            wrapped.topAnchor.constraint(equalTo: topAnchor),
            wrapped.bottomAnchor.constraint(equalTo: bottomAnchor),
            wrapped.leadingAnchor.constraint(equalTo: leadingAnchor),
            wrapped.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    private func makeRow(title: String, value: String) -> UIView {
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
}
