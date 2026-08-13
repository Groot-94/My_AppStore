//
//  SeeAllBuilder.swift
//  SeeAllInterface
//
//  Created by groot on 7/29/26.
//

import UIKit

/// 차트 피드 종류. Interface 가 소유(ITunesKit 비의존 유지).
public enum ChartFeedKind: Sendable {
    case topFree
    case topPaid
}

/// SeeAll 화면 입력. Interface 가 소유하는 공개 타입.
public struct SeeAllInput: Sendable {
    public let title: String
    public let feed: ChartFeedKind
    public let genreID: Int?

    public init(title: String, feed: ChartFeedKind, genreID: Int?) {
        self.title = title
        self.feed = feed
        self.genreID = genreID
    }
}

/// SeeAll 진입 계약.
/// `build` 가 UIViewController 를 생성하므로 메인 액터에서 수행한다.
@MainActor
public protocol SeeAllBuilder {
    func build(input: SeeAllInput) -> UIViewController
}

/// SeeAll 상향 이벤트 계약. 피처는 이 delegate 로만 라우팅 의사를 방출하고 App 이 목적지를 소유한다.
@MainActor
public protocol SeeAllRouting: AnyObject {
    func seeAllDidSelectApp(id: Int)
}
