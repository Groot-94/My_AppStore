//
//  RatingView.swift
//  DesignSystem
//
//  Created by groot on 7/29/26.
//

import UIKit

/// 평점 표시 뷰(별 아이콘 + 수치/리뷰 수). 엔티티 비의존 — 원시 값 입력.
public final class RatingView: UIView {
    private let starImageView = UIImageView()
    private let label = UILabel()
    private let stack = UIStackView()

    public init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        starImageView.image = UIImage(systemName: "star.fill")
        starImageView.tintColor = AppColors.ratingStar
        starImageView.contentMode = .scaleAspectFit
        starImageView.setContentHuggingPriority(.required, for: .horizontal)

        label.font = AppFont.caption
        label.textColor = AppColors.secondaryLabel

        stack.axis = .horizontal
        stack.spacing = 2
        stack.alignment = .center
        stack.addArrangedSubview(starImageView)
        stack.addArrangedSubview(label)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            starImageView.widthAnchor.constraint(equalToConstant: 11),
            starImageView.heightAnchor.constraint(equalToConstant: 11),
        ])
    }

    /// - Parameters:
    ///   - rating: 평균 평점(0...5).
    ///   - count: 리뷰 수(nil 이면 숨김).
    public func configure(rating: Double, count: Int?) {
        if let count {
            label.text = String(format: "%.1f · %@", rating, Self.abbreviate(count))
        } else {
            label.text = String(format: "%.1f", rating)
        }
    }

    private static func abbreviate(_ count: Int) -> String {
        switch count {
        case 1_000_000...:
            return String(format: "%.1f천만", Double(count) / 10_000_000)
        case 10_000...:
            return String(format: "%.0f만", Double(count) / 10_000)
        case 1_000...:
            return String(format: "%.1f천", Double(count) / 1_000)
        default:
            return "\(count)"
        }
    }
}
