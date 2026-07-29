import UIKit
import Persistence

/// 목록 행 셀(아이콘·이름·부제·평점·받기). Search 결과/차트 행 공용.
///
/// 엔티티 비의존 — 자체 `Model` 로 입력받는다(피처가 엔티티→Model 변환).
public final class AppRowCell: UITableViewCell {
    public static let reuseID = "AppRowCell"

    /// 셀 구성 모델(원시 값만).
    public struct Model: Sendable, Equatable {
        public let iconURL: URL?
        public let title: String
        public let subtitle: String
        /// 평점(nil 이면 평점 뷰 숨김).
        public let rating: Double?
        public let ratingCount: Int?
        /// 받기 버튼 문구(nil 이면 버튼 숨김).
        public let actionTitle: String?

        public init(
            iconURL: URL?,
            title: String,
            subtitle: String,
            rating: Double? = nil,
            ratingCount: Int? = nil,
            actionTitle: String? = "받기"
        ) {
            self.iconURL = iconURL
            self.title = title
            self.subtitle = subtitle
            self.rating = rating
            self.ratingCount = ratingCount
            self.actionTitle = actionTitle
        }
    }

    private let iconView = AppIconView(cornerRadius: 12)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let ratingView = RatingView()
    private let getButton = GetButton()
    private let textStack = UIStackView()

    /// 받기 버튼 탭 콜백.
    public var onGetTapped: (() -> Void)?

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        selectionStyle = .none
        backgroundColor = .clear

        titleLabel.font = AppFont.body
        titleLabel.textColor = AppColors.label
        titleLabel.numberOfLines = 1

        subtitleLabel.font = AppFont.caption
        subtitleLabel.textColor = AppColors.secondaryLabel
        subtitleLabel.numberOfLines = 1

        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.alignment = .leading
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(subtitleLabel)
        textStack.addArrangedSubview(ratingView)

        getButton.onTap = { [weak self] in self?.onGetTapped?() }

        for view in [iconView, textStack, getButton] {
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8),
            iconView.widthAnchor.constraint(equalToConstant: 56),
            iconView.heightAnchor.constraint(equalToConstant: 56),

            textStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: getButton.leadingAnchor, constant: -12),

            getButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            getButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    /// 셀 구성. 이미지 로더는 별도 주입(재사용 성능).
    public func configure(with model: Model, loader: ImageLoading?) {
        if let loader { iconView.configure(loader: loader) }
        iconView.setImage(url: model.iconURL)
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle

        if let rating = model.rating {
            ratingView.isHidden = false
            ratingView.configure(rating: rating, count: model.ratingCount)
        } else {
            ratingView.isHidden = true
        }

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
