//
//  AppDetailReleaseNotesView.swift
//  AppDetail
//
//  Created by groot on 8/9/26.
//

import UIKit
import DesignSystem

/// 새로운 기능 섹션(버전 줄 + 릴리즈 노트).
final class AppDetailReleaseNotesView: UIView {

    init(versionLine: String, notes: String) {
        super.init(frame: .zero)
        setup(versionLine: versionLine, notes: notes)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup(versionLine: String, notes: String) {
        let versionLabel = UILabel()
        versionLabel.text = versionLine
        versionLabel.font = AppFont.subheadline
        versionLabel.textColor = AppColors.secondaryLabel

        let notesLabel = UILabel()
        notesLabel.text = notes
        notesLabel.font = AppFont.body
        notesLabel.textColor = AppColors.label
        notesLabel.numberOfLines = 0

        let column = UIStackView(arrangedSubviews: [versionLabel, notesLabel])
        column.axis = .vertical
        column.spacing = 8

        let section = UIStackView(arrangedSubviews: [AppDetailSection.title("새로운 기능"), column])
        section.axis = .vertical
        section.spacing = 8

        let wrapped = AppDetailSection.wrapInMargins(section)
        wrapped.translatesAutoresizingMaskIntoConstraints = false
        addSubview(wrapped)
        NSLayoutConstraint.activate([
            wrapped.topAnchor.constraint(equalTo: topAnchor),
            wrapped.bottomAnchor.constraint(equalTo: bottomAnchor),
            wrapped.leadingAnchor.constraint(equalTo: leadingAnchor),
            wrapped.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}
