//
//  PlaceholderViewController.swift
//  AppDetail
//
//  Created by groot on 7/29/26.
//

import UIKit
import DesignSystem

/// Placeholder: 피처 이름 레이블만 중앙에 표시.
final class PlaceholderViewController: UIViewController {
    private let labelText: String

    init(label: String) {
        self.labelText = label
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) unavailable") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background

        let label = UILabel()
        label.text = labelText
        label.font = AppFont.title
        label.textColor = AppColors.accent
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
        ])
    }
}
