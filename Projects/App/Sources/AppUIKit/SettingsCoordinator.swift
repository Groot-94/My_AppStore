//
//  SettingsCoordinator.swift
//  AppUIKit
//
//  Created by groot on 8/13/26.
//

import UIKit

/// App 소유의 모달 설정 플로우. 부모 router 에 모달을 present 하고, 닫히면 `onFinish` 로 종료를 알린다.
///
/// 자식 코디네이터 생명주기(attach/detach)의 실제 사용처 — 부모(AppCoordinator)가 `attach` 후 `start` 하고,
/// 닫기/스와이프 dismiss 시 `onFinish` 로 detach 된다.
@MainActor
final class SettingsCoordinator: Coordinator {
    var onFinish: (() -> Void)?

    private let parentRouter: Router

    init(parentRouter: Router) {
        self.parentRouter = parentRouter
    }

    func start() {
        let settings = SettingsViewController()
        settings.onClose = { [weak self] in
            self?.parentRouter.dismiss(animated: true)
        }
        let modal = UINavigationController(rootViewController: settings)
        parentRouter.present(modal, animated: true, onDismiss: { [weak self] in
            self?.onFinish?()
        })
    }
}
