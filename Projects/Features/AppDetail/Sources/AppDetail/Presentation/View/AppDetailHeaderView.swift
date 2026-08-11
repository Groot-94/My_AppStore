//
//  AppDetailHeaderView.swift
//  AppDetail
//
//  Created by groot on 8/9/26.
//

import UIKit
import DesignSystem
import CoreKit

/// 상세 헤더(아이콘 · 이름/판매자 · 받기 버튼). 표시에 필요한 값만 입력받는다.
final class AppDetailHeaderView: UIView {

    init(name: String, sellerName: String, iconURL: URL?, priceText: String, imageLoader: ImageLoading) {
        super.init(frame: .zero)
        setup(
            name: name,
            sellerName: sellerName,
            iconURL: iconURL,
            priceText: priceText,
            imageLoader: imageLoader
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup(
        name: String,
        sellerName: String,
        iconURL: URL?,
        priceText: String,
        imageLoader: ImageLoading
    ) {
        let icon = AppIconView(cornerRadius: 20)
        icon.setImage(url: iconURL, loader: imageLoader)
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 96),
            icon.heightAnchor.constraint(equalToConstant: 96),
        ])

        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = AppFont.bold(.title2)
        nameLabel.textColor = AppColors.label
        nameLabel.numberOfLines = 2

        let sellerLabel = UILabel()
        sellerLabel.text = sellerName
        sellerLabel.font = AppFont.subheadline
        sellerLabel.textColor = AppColors.secondaryLabel
        sellerLabel.numberOfLines = 1

        let getButton = GetButton()
        getButton.configure(title: priceText)
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
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: topAnchor),
            row.bottomAnchor.constraint(equalTo: bottomAnchor),
            row.leadingAnchor.constraint(equalTo: leadingAnchor),
            row.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}
