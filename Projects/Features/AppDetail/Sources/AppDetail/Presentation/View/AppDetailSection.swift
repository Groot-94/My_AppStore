//
//  AppDetailSection.swift
//  AppDetail
//
//  Created by groot on 8/9/26.
//

import UIKit
import DesignSystem

/// 상세 화면 섹션들이 공유하는 조판 규칙. 섹션 뷰들이 같은 제목 스타일·여백을 쓰도록 한곳에 둔다.
enum AppDetailSection {

    /// 섹션 제목 라벨.
    static func title(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = AppFont.bold(.title3)
        label.textColor = AppColors.label
        return label
    }

    /// 좌우 16pt 여백을 적용해 감싼다(가로 스크롤 섹션은 자체 인셋 사용).
    static func wrapInMargins(_ content: UIView) -> UIView {
        let container = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: container.topAnchor),
            content.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
        ])
        return container
    }
}
