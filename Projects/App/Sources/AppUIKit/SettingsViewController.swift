//
//  SettingsViewController.swift
//  AppUIKit
//
//  Created by groot on 8/13/26.
//

import UIKit

/// App 소유의 간단한 설정 화면. 피처와 무관하며 모달 플로우 시연용으로 App 이 직접 소유한다.
///
/// "닫기" 바 버튼을 누르면 `onClose` 로 상위(코디네이터)에 종료를 알린다.
final class SettingsViewController: UIViewController {
    var onClose: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "설정"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )

        let label = UILabel()
        label.text = "여기는 App 이 소유하는 설정 화면입니다.\n닫기 또는 아래로 스와이프해 닫을 수 있습니다."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
    }

    @objc private func closeTapped() {
        onClose?()
    }
}
