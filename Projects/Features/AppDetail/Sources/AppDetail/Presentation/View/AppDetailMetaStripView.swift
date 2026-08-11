//
//  AppDetailMetaStripView.swift
//  AppDetail
//
//  Created by groot on 8/9/26.
//

import UIKit
import DesignSystem

/// 평점·연령·카테고리 등을 구분선으로 나눠 가로 스크롤로 보여주는 메타 스트립.
final class AppDetailMetaStripView: UIView {

    private static let height: CGFloat = 56

    init(cells: [AppDetailPresentation.MetaCell]) {
        super.init(frame: .zero)
        setup(cells: cells)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup(cells: [AppDetailPresentation.MetaCell]) {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        for (index, cell) in cells.enumerated() {
            stack.addArrangedSubview(makeCell(caption: cell.caption, value: cell.value))
            if index < cells.count - 1 {
                stack.addArrangedSubview(makeDivider())
            }
        }

        scroll.addSubview(stack)
        addSubview(scroll)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: topAnchor),
            scroll.bottomAnchor.constraint(equalTo: bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: trailingAnchor),

            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            stack.heightAnchor.constraint(equalTo: scroll.frameLayoutGuide.heightAnchor),
            scroll.heightAnchor.constraint(equalToConstant: Self.height),
        ])
    }

    private func makeCell(caption: String, value: String) -> UIView {
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = AppFont.bold(.subheadline)
        valueLabel.textColor = AppColors.secondaryLabel
        valueLabel.textAlignment = .center

        let captionLabel = UILabel()
        captionLabel.text = caption
        captionLabel.font = AppFont.caption
        captionLabel.textColor = AppColors.tertiaryLabel
        captionLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [valueLabel, captionLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return stack
    }

    private func makeDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = AppColors.separator
        divider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            divider.widthAnchor.constraint(equalToConstant: 1.0 / max(UIScreen.main.scale, 1)),
            divider.heightAnchor.constraint(equalToConstant: 32),
        ])
        return divider
    }
}
