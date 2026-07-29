import Foundation
import Networking
import CoreKit

/// iTunes API 3종 엔드포인트 정의(docs/04-data-api.md).
///
/// `StoreConfig` 로 country/lang 을 적용한다. Networking 의 `Endpoint` 로 변환한다.
enum ITunesEndpoint {
    static let searchHost = "itunes.apple.com"
    static let rssHost = "rss.applemarketingtools.com"

    /// Search: `/search?term&country&media=software&entity=software&limit&lang`
    static func search(term: String, genreID: Int?, limit: Int, config: StoreConfig) -> Endpoint {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "country", value: config.country),
            URLQueryItem(name: "media", value: "software"),
            URLQueryItem(name: "entity", value: "software"),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "lang", value: config.lang),
        ]
        if let genreID {
            items.append(URLQueryItem(name: "genreId", value: String(genreID)))
        }
        return Endpoint(host: searchHost, path: "/search", queryItems: items)
    }

    /// Lookup: `/lookup?id=1,2,3&country&lang`
    static func lookup(ids: [Int], config: StoreConfig) -> Endpoint {
        let items: [URLQueryItem] = [
            URLQueryItem(name: "id", value: ids.map(String.init).joined(separator: ",")),
            URLQueryItem(name: "country", value: config.country),
            URLQueryItem(name: "lang", value: config.lang),
        ]
        return Endpoint(host: searchHost, path: "/lookup", queryItems: items)
    }

    /// RSS 차트: `/api/v2/{country}/apps/{feed}/{limit}/apps.json`
    static func chart(feed: ChartFeed, limit: Int, config: StoreConfig) -> Endpoint {
        Endpoint(
            host: rssHost,
            path: "/api/v2/\(config.country)/apps/\(feed.rawValue)/\(limit)/apps.json"
        )
    }
}
