//
//  ChartRowView.swift
//  DesignSystem
//
//  Created by groot on 7/30/26.
//

import UIKit
import CoreKit

/// 차트 순위 행(순번 + 아이콘 + 이름/장르 + 받기 버튼). 세로 스택에 직접 넣는 `UIControl`.
///
/// 행 전체 탭은 `onTap`, 받기 버튼 탭은 `onGetTap` 으로 분리된다. 받기 버튼(UIControl)이
/// 자체 터치를 소비하므로 별도 제스처 조율 없이 두 탭이 겹치지 않는다.
public final class ChartRowView: UIControl {

    /// 행 구성 모델.
    public struct Model: Sendable, Equatable {
        public let rank: Int
        public let iconURL: URL?
        public let title: String
        public let subtitle: String
        public let actionTitle: String?

        public init(
            rank: Int,
            iconURL: URL?,
            title: String,
            subtitle: String,
            actionTitle: String? = "받기"
        ) {
            self.rank = rank
            self.iconURL = iconURL
            self.title = title
            self.subtitle = subtitle
            self.actionTitle = actionTitle
        }
    }

    private let rankLabel = UILabel()
    private let iconView = AppIconView(cornerRadius: 12)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let getButton = GetButton()

    /// 행 전체 탭 콜백. nil 이면 행 탭을 소비하지 않는다(셀 래퍼가 상위 selection 에 위임).
    public var onTap: (() -> Void)?
    /// 받기 버튼 탭 콜백.
    public var onGetTap: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        rankLabel.font = AppFont.subheadline
        rankLabel.textColor = AppColors.secondaryLabel
        rankLabel.textAlignment = .center
        rankLabel.setContentHuggingPriority(.required, for: .horizontal)

        titleLabel.font = AppFont.body
        titleLabel.textColor = AppColors.label
        titleLabel.numberOfLines = 1

        subtitleLabel.font = AppFont.caption
        subtitleLabel.textColor = AppColors.secondaryLabel
        subtitleLabel.numberOfLines = 1

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.isUserInteractionEnabled = false

        rankLabel.isUserInteractionEnabled = false
        iconView.isUserInteractionEnabled = false

        getButton.onTap = { [weak self] in self?.onGetTap?() }
        addAction(UIAction { [weak self] _ in self?.onTap?() }, for: .touchUpInside)

        for view in [rankLabel, iconView, textStack, getButton] {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }

        NSLayoutConstraint.activate([
            rankLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            rankLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 24),

            iconView.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 8),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 8),
            iconView.widthAnchor.constraint(equalToConstant: 52),
            iconView.heightAnchor.constraint(equalToConstant: 52),

            textStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            textStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: getButton.leadingAnchor, constant: -12),

            getButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            getButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    // 행 탭 콜백이 없으면(셀 래퍼 경로) 받기 버튼 외 영역의 터치를 상위로 흘려보내
    // collectionView 의 selection 이 동작하게 한다. 받기 버튼은 계속 자체 터치를 받는다.
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        if onTap == nil, hit === self { return nil }
        return hit
    }

    public func configure(with model: Model, loader: ImageLoading?) {
        rankLabel.text = "\(model.rank)"
        if let loader { iconView.configure(loader: loader) }
        iconView.setImage(url: model.iconURL)
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
        if let actionTitle = model.actionTitle {
            getButton.isHidden = false
            getButton.configure(title: actionTitle)
        } else {
            getButton.isHidden = true
        }
    }

    /// 재사용 전 상태 초기화(셀 래퍼가 호출).
    public func prepareForReuse() {
        iconView.setImage(url: nil)
        onTap = nil
        onGetTap = nil
    }
}
