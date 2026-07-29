import UIKit

/// 카테고리 그리드(정적 목록). 엔티티 비의존 — 자체 `Item` 배열 입력.
public final class CategoryGridView: UIView {
    /// 카테고리 항목.
    public struct Item: Sendable, Equatable {
        public let id: Int
        public let title: String
        /// SF Symbol 이름(선택).
        public let symbolName: String?

        public init(id: Int, title: String, symbolName: String? = nil) {
            self.id = id
            self.title = title
            self.symbolName = symbolName
        }
    }

    private let stack = UIStackView()
    private var items: [Item] = []

    /// 카테고리 탭 콜백(항목 id 전달).
    public var onSelect: ((Int) -> Void)?

    public init() {
        super.init(frame: .zero)
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public func configure(items: [Item]) {
        self.items = items
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, item) in items.enumerated() {
            stack.addArrangedSubview(makeRow(item))
            if index < items.count - 1 {
                stack.addArrangedSubview(makeSeparator())
            }
        }
    }

    private func makeRow(_ item: Item) -> UIView {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.title = item.title
        config.baseForegroundColor = AppColors.label
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        if let symbolName = item.symbolName {
            config.image = UIImage(systemName: symbolName)
            config.imagePadding = 12
            config.baseForegroundColor = AppColors.accent
        }
        config.titleAlignment = .leading
        button.configuration = config
        button.contentHorizontalAlignment = .leading
        button.addAction(UIAction { [weak self] _ in self?.onSelect?(item.id) }, for: .touchUpInside)
        return button
    }

    private func makeSeparator() -> UIView {
        let line = UIView()
        line.backgroundColor = AppColors.separator
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale).isActive = true
        return line
    }
}
