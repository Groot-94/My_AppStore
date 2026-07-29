import Foundation

/// 스토어 국가/언어 상수. AppUIKit 에서 등록해 주입한다.
public struct StoreConfig: Sendable, Equatable {
    public let country: String
    public let lang: String

    public init(country: String, lang: String) {
        self.country = country
        self.lang = lang
    }

    /// 기본값: 한국 스토어(docs/04-data-api.md).
    public static let korea = StoreConfig(country: "kr", lang: "ko_kr")
}
