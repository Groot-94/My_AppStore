//
//  NavigationRouter.swift
//  App
//
//  Created by groot on 8/13/26.
//

import UIKit

/// `UINavigationController` 기반 Router 구현. 네비게이션 스택은 루트(AppCoordinator)가 소유해 주입한다.
///
/// `present` 시 제시된 컨트롤러의 `presentationController.delegate` 를 자신으로 지정해,
/// 아래로 스와이프해 내리는 dismiss 도 `onDismiss` 로 잡는다(닫기 버튼 경로와 동일하게 처리되도록).
@MainActor
final class NavigationRouter: NSObject, Router, UIAdaptivePresentationControllerDelegate {
    let navigationController: UINavigationController

    /// 현재 모달로 제시 중인 화면의 dismiss 콜백. 스와이프/프로그램 dismiss 양쪽에서 1회 호출 후 해제한다.
    private var onDismissForPresented: (() -> Void)?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func setRoot(_ vc: UIViewController) {
        navigationController.setViewControllers([vc], animated: false)
    }

    func push(_ vc: UIViewController, animated: Bool) {
        navigationController.pushViewController(vc, animated: animated)
    }

    func present(_ vc: UIViewController, animated: Bool, onDismiss: (() -> Void)?) {
        onDismissForPresented = onDismiss
        vc.presentationController?.delegate = self
        navigationController.present(vc, animated: animated)
    }

    func dismiss(animated: Bool) {
        let onDismiss = onDismissForPresented
        onDismissForPresented = nil
        navigationController.dismiss(animated: animated) {
            onDismiss?()
        }
    }

    func popToRoot(animated: Bool) {
        navigationController.popToRootViewController(animated: animated)
    }

    // MARK: - UIAdaptivePresentationControllerDelegate

    /// 스와이프 dismiss. `dismiss(animated:)` 를 거치지 않으므로 여기서 콜백을 소진한다.
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        let onDismiss = onDismissForPresented
        onDismissForPresented = nil
        onDismiss?()
    }
}
