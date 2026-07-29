//
//  ArcadeBannerView.swift
//  Arcade
//
//  Created by groot on 7/29/26.
//

import UIKit
import DesignSystem

/// 정적 그라데이션 배너(히어로 / 구독 안내 공용). 카피만 표시, 탭 동작 없음.
final class ArcadeBannerView: UIView {
    /// 배너 스타일(그라데이션 색·높이 구분).
    enum Style {
        case hero
        case subscription
    }

    private let gradientLayer = CAGradientLayer()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let style: Style

    init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        layer.cornerRadius = 18
        layer.cornerCurve = .continuous
        clipsToBounds = true

        switch style {
        case .hero:
            gradientLayer.colors = [UIColor.systemPink.cgColor, UIColor.systemOrange.cgColor]
        case .subscription:
            gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemTeal.cgColor]
        }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)

        titleLabel.font = AppFont.bold(style == .hero ? .largeTitle : .title3)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2

        subtitleLabel.font = AppFont.subheadline
        subtitleLabel.textColor = .white.withAlphaComponent(0.9)
        subtitleLabel.numberOfLines = 2

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        let minHeight: CGFloat = (style == .hero) ? 180 : 120
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 20),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -20),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
