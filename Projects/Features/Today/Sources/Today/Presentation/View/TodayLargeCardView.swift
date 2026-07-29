//
//  TodayLargeCardView.swift
//  Today
//
//  Created by groot on 7/29/26.
//

import UIKit
import DesignSystem
import CoreKit

/// 대형 피처 카드(피처 소유 뷰). 커버는 그라데이션 + 대표 앱 아이콘으로 구성.
final class TodayLargeCardView: UIView {
    /// 앱 선택 콜백(카드 탭/앱 행 탭 공통 — appID 전달).
    var onSelect: ((Int) -> Void)?

    private let container = UIView()
    private let gradientLayer = CAGradientLayer()
    private let eyebrowLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let appRow = TodayAppRowView()
    private var primaryAppID: Int?

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        container.layer.cornerRadius = 18
        container.layer.cornerCurve = .continuous
        container.clipsToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)

        gradientLayer.colors = [UIColor.systemIndigo.cgColor, UIColor.systemPurple.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        container.layer.insertSublayer(gradientLayer, at: 0)

        eyebrowLabel.font = AppFont.bold(.caption1)
        eyebrowLabel.textColor = .white.withAlphaComponent(0.85)

        titleLabel.font = AppFont.bold(.title2)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2

        subtitleLabel.font = AppFont.subheadline
        subtitleLabel.textColor = .white.withAlphaComponent(0.9)
        subtitleLabel.numberOfLines = 2

        let textStack = UIStackView(arrangedSubviews: [eyebrowLabel, titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.setCustomSpacing(8, after: titleLabel)

        appRow.backgroundStyle = .translucentLight
        appRow.onSelect = { [weak self] id in self?.onSelect?(id) }

        let stack = UIStackView(arrangedSubviews: [textStack, appRow])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 320),

            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
            stack.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor, constant: 20),
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        container.addGestureRecognizer(tap)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = container.bounds
    }

    func configure(with card: TodayCard, loader: ImageLoading) {
        eyebrowLabel.text = card.eyebrow.uppercased()
        titleLabel.text = card.title
        subtitleLabel.text = card.subtitle
        primaryAppID = card.primaryApp?.id
        if let app = card.primaryApp {
            appRow.isHidden = false
            appRow.configure(with: app, loader: loader)
        } else {
            appRow.isHidden = true
        }
    }

    @objc
    private func cardTapped() {
        guard let primaryAppID else { return }
        onSelect?(primaryAppID)
    }
}
