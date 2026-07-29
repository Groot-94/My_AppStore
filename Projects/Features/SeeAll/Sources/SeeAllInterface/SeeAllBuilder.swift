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
public protocol SeeAllBuilder {
    func build(input: SeeAllInput) -> UIViewController
}
