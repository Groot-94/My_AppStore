//
//  SearchRecentCell.swift
//  Search
//
//  Created by groot on 7/29/26.
//

import UIKit
import DesignSystem

/// 최근 검색어 행. 돋보기 아이콘 + 검색어 텍스트.
final class SearchRecentCell: UITableViewCell {
    static let reuseID = "SearchRecentCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .default
        backgroundColor = .clear
        imageView?.tintColor = AppColors.secondaryLabel
        textLabel?.font = AppFont.body
        textLabel?.textColor = AppColors.accent
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) unavailable") }

    func configure(term: String) {
        textLabel?.text = term
        imageView?.image = UIImage(systemName: "magnifyingglass")
    }
}
