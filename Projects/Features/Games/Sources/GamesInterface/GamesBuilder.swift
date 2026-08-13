//
//  GamesBuilder.swift
//  GamesInterface
//
//  Created by groot on 7/29/26.
//

import UIKit

/// Games 진입 계약.
/// `build` 가 UIViewController 를 생성하므로 메인 액터에서 수행한다.
@MainActor
public protocol GamesBuilder {
    func build() -> UIViewController
}

/// Games 차트 종류. Interface 가 소유(SeeAll 비의존 유지) — App 이 SeeAll 입력으로 매핑한다.
public enum GamesChartKind: Sendable {
    case topFree
    case topPaid
}

/// Games 상향 이벤트 계약. 피처는 이 delegate 로만 라우팅 의사를 방출하고 App 이 목적지를 소유한다.
@MainActor
public protocol GamesRouting: AnyObject {
    func gamesDidSelectApp(id: Int)
    func gamesDidRequestSeeAll(title: String, kind: GamesChartKind, genreID: Int?)
}
