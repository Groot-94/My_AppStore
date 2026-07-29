//
//  GetButton.swift
//  DesignSystem
//
//  Created by groot on 7/29/26.
//

import UIKit

/// "받기" 버튼. 다운로드 동작 없이 탭 콜백만 노출한다.
public final class GetButton: UIButton {
    /// 탭 콜백.
    public var onTap: (() -> Void)?

    public init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        var config = UIButton.Configuration.gray()
        config.cornerStyle = .capsule
        config.baseForegroundColor = AppColors.accent
        config.buttonSize = .small
        configuration = config

        addAction(UIAction { [weak self] _ in self?.onTap?() }, for: .touchUpInside)
        setContentHuggingPriority(.required, for: .horizontal)
    }

    /// - Parameter title: 표시 문구("받기" / "₩1,100" 등).
    public func configure(title: String) {
        var config = configuration
        var attr = AttributedString(title)
        attr.font = AppFont.bold(.subheadline)
        config?.attributedTitle = attr
        configuration = config
    }
}
