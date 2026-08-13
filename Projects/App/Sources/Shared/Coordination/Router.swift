//
//  Router.swift
//  App
//
//  Created by groot on 8/13/26.
//

import UIKit

/// 화면 제시(navigation stack 조작)를 코디네이터에서 분리한 계약.
///
/// 코디네이터는 "어디로 갈지"만 결정하고, "어떻게 보여줄지"(push/present/dismiss)는 Router 가 맡는다.
@MainActor
protocol Router: AnyObject {
    func setRoot(_ vc: UIViewController)
    func push(_ vc: UIViewController, animated: Bool)
    func present(_ vc: UIViewController, animated: Bool, onDismiss: (() -> Void)?)
    func dismiss(animated: Bool)
    func popToRoot(animated: Bool)
}
