//
//  TodayAppRowView.swift
//  Today
//
//  Created by groot on 7/29/26.
//

import UIKit
import DesignSystem
import CoreKit

/// 카드 내부 앱 행(아이콘 · 이름/장르 · 받기 버튼). 카드 배경에 따라 텍스트 대비를 바꾼다.
final class TodayAppRowView: UIView {
    /// 카드 배경 스타일(대형 카드는 반투명 라이트, 리스트 카드는 기본).
    enum BackgroundStyle {
        case plain
        case translucentLight
    }

    /// 앱 선택 콜백(appID 전달).
    var onSelect: ((Int) -> Void)?
    var backgroundStyle: BackgroundStyle = .plain { didSet { applyStyle() } }

    private let iconView = AppIconView(cornerRadius: 12)
    private let nameLabel = UILabel()
    private let genreLabel = UILabel()
    private let getButton = GetButton()
    private var appID: Int?

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        nameLabel.font = AppFont.bold(.body)
        nameLabel.numberOfLines = 1
        genreLabel.font = AppFont.caption
        genreLabel.numberOfLines = 1

        let textStack = UIStackView(arrangedSubviews: [nameLabel, genreLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.alignment = .leading

        getButton.onTap = { [weak self] in
            self?.getButton.configure(title: CommonStrings.Action.open)
        }

        for view in [iconView, textStack, getButton] {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            iconView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 52),
            iconView.heightAnchor.constraint(equalToConstant: 52),

            textStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            textStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: getButton.leadingAnchor, constant: -12),

            getButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            getButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            heightAnchor.constraint(greaterThanOrEqualToConstant: 52),
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(rowTapped))
        addGestureRecognizer(tap)
        applyStyle()
    }

    private func applyStyle() {
        switch backgroundStyle {
        case .plain:
            nameLabel.textColor = AppColors.label
            genreLabel.textColor = AppColors.secondaryLabel
        case .translucentLight:
            nameLabel.textColor = .white
            genreLabel.textColor = .white.withAlphaComponent(0.85)
        }
    }

    func configure(with app: TodayAppSummary, loader: ImageLoading) {
        appID = app.id
        iconView.setImage(url: app.iconURL, loader: loader)
        nameLabel.text = app.name
        genreLabel.text = app.genre
        getButton.configure(title: app.priceText)
    }

    @objc
    private func rowTapped(_ gesture: UITapGestureRecognizer) {
        // 받기 버튼(UIControl) 위 터치는 셀 탭으로 처리하지 않는다.
        let location = gesture.location(in: self)
        if getButton.frame.contains(location) { return }
        guard let appID else { return }
        onSelect?(appID)
    }
}
