//
//  CarouselView.swift
//  DesignSystem
//
//  Created by groot on 7/29/26.
//

import UIKit
import CoreKit

/// 추천 앱 가로 캐러셀(Apps/Games 히어로). 엔티티 비의존 — 자체 `Item` 배열 입력.
public final class CarouselView: UIView {
    /// 캐러셀 항목.
    public struct Item: Sendable, Equatable {
        public let id: Int
        public let imageURL: URL?
        public let title: String
        public let subtitle: String

        public init(id: Int, imageURL: URL?, title: String, subtitle: String) {
            self.id = id
            self.imageURL = imageURL
            self.title = title
            self.subtitle = subtitle
        }
    }

    private let collectionView: UICollectionView
    private var items: [Item] = []
    private var loader: ImageLoading?

    /// 항목 탭 콜백(항목 id 전달).
    public var onSelect: ((Int) -> Void)?

    public init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: CarouselCell.reuseID)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    public func configure(items: [Item], loader: ImageLoading?) {
        self.items = items
        self.loader = loader
        collectionView.reloadData()
    }
}

extension CarouselView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CarouselCell.reuseID,
            for: indexPath
        )
        if let cell = cell as? CarouselCell {
            cell.configure(with: items[indexPath.item], loader: loader)
        }
        return cell
    }
}

extension CarouselView: UICollectionViewDelegateFlowLayout {
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = max(collectionView.bounds.width - 64, 0)
        return CGSize(width: width, height: collectionView.bounds.height)
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelect?(items[indexPath.item].id)
    }
}

/// 캐러셀 셀(내부 전용).
final class CarouselCell: UICollectionViewCell {
    static let reuseID = "CarouselCell"
    private let imageView = AppIconView(cornerRadius: 16)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        subtitleLabel.font = AppFont.caption
        subtitleLabel.textColor = AppColors.secondaryLabel
        titleLabel.font = AppFont.bold(.headline)
        titleLabel.textColor = AppColors.label

        let textStack = UIStackView(arrangedSubviews: [subtitleLabel, titleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let stack = UIStackView(arrangedSubviews: [textStack, imageView])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with item: CarouselView.Item, loader: ImageLoading?) {
        subtitleLabel.text = item.subtitle.uppercased()
        titleLabel.text = item.title
        imageView.setImage(url: item.imageURL, loader: loader)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.setImage(url: nil)
    }
}
