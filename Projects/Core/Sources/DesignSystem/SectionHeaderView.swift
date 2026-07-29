import UIKit

/// 섹션 헤더(제목 + 선택적 "모두 보기"). 엔티티 비의존 — 원시 값 입력.
public final class SectionHeaderView: UICollectionReusableView {
    public static let reuseID = "SectionHeaderView"

    private let titleLabel = UILabel()
    private let seeAllButton = UIButton(type: .system)

    /// "모두 보기" 탭 콜백(설정 시에만 버튼 표시).
    public var onSeeAll: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        titleLabel.font = AppFont.bold(.title3)
        titleLabel.textColor = AppColors.label

        seeAllButton.setTitle("모두 보기", for: .normal)
        seeAllButton.titleLabel?.font = AppFont.subheadline
        seeAllButton.setTitleColor(AppColors.accent, for: .normal)
        seeAllButton.addAction(UIAction { [weak self] _ in self?.onSeeAll?() }, for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titleLabel, UIView(), seeAllButton])
        stack.axis = .horizontal
        stack.alignment = .firstBaseline
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    /// - Parameters:
    ///   - title: 섹션 제목.
    ///   - showsSeeAll: "모두 보기" 노출 여부.
    public func configure(title: String, showsSeeAll: Bool) {
        titleLabel.text = title
        seeAllButton.isHidden = !showsSeeAll
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        onSeeAll = nil
    }
}
