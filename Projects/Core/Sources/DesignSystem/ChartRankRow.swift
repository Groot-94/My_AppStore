import UIKit
import Persistence

/// 차트 순위 행(순번 + 아이콘 + 이름/장르). SeeAll·차트 목록 공용.
///
/// 엔티티 비의존 — 자체 `Model` 로 입력.
public final class ChartRankRow: UICollectionViewCell {
    public static let reuseID = "ChartRankRow"

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

    public var onGetTapped: (() -> Void)?

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

        getButton.onTap = { [weak self] in self?.onGetTapped?() }

        for view in [rankLabel, iconView, textStack, getButton] {
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }

        NSLayoutConstraint.activate([
            rankLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            rankLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 24),

            iconView.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 8),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8),
            iconView.widthAnchor.constraint(equalToConstant: 52),
            iconView.heightAnchor.constraint(equalToConstant: 52),

            textStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: getButton.leadingAnchor, constant: -12),

            getButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            getButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
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

    public override func prepareForReuse() {
        super.prepareForReuse()
        iconView.setImage(url: nil)
        onGetTapped = nil
    }
}
