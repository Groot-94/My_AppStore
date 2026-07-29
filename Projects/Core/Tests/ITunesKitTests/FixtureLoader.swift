import Foundation
import Testing

/// 번들 리소스(픽스처 JSON) 로더.
enum FixtureLoader {
    static func data(_ name: String) throws -> Data {
        let bundle = Bundle(for: BundleToken.self)
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            throw Failure.missing(name)
        }
        return try Data(contentsOf: url)
    }

    enum Failure: Error { case missing(String) }

    private final class BundleToken {}
}
