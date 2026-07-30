//
//  ChartRankRow.swift
//  DesignSystem
//
//  Created by groot on 7/30/26.
//

import UIKit
import CoreKit

/// `ChartRowView` 를 감싼 컬렉션 뷰 셀. SeeAll 등 셀 기반 목록 경로에서 사용한다.
/// 행 선택은 collectionView 의 `didSelectItemAt` 이 담당하고, 받기 버튼 탭만 `onGetTapped` 로 노출한다.
public final class ChartRankRow: UICollectionViewCell {
    public static let reuseID = "ChartRankRow"

    public typealias Model = ChartRowView.Model

    private let rowView = ChartRowView()

    public var onGetTapped: (() -> Void)? {
        get { rowView.onGetTap }
        set { rowView.onGetTap = newValue }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        rowView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rowView)
        NSLayoutConstraint.activate([
            rowView.topAnchor.constraint(equalTo: contentView.topAnchor),
            rowView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            rowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            rowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public func configure(with model: Model, loader: ImageLoading?) {
        rowView.configure(with: model, loader: loader)
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        rowView.prepareForReuse()
    }
}
