import Foundation

/// 이미지 로딩 추상화(DesignSystem 이 주입받아 사용).
public protocol ImageLoading: Sendable {
    /// URL 이미지 원본 데이터를 로드한다(캐시 우선).
    func loadImageData(from url: URL) async throws -> Data
}

/// URLSession + Cache 기반 이미지 로더.
///
/// 캐시 hit 이면 네트워크를 건너뛴다. miss 이면 다운로드 후 저장한다.
public struct DefaultImageLoader: ImageLoading {
    private let session: URLSession
    private let cache: Cache
    private let ttl: TimeInterval

    /// - Parameters:
    ///   - cache: 이미지 저장 캐시.
    ///   - session: URLSession(기본 `.shared`).
    ///   - ttl: 이미지 캐시 만료(초). 기본 24시간.
    public init(cache: Cache, session: URLSession = .shared, ttl: TimeInterval = 86_400) {
        self.cache = cache
        self.session = session
        self.ttl = ttl
    }

    public func loadImageData(from url: URL) async throws -> Data {
        let key = url.absoluteString
        if let cached = cache.data(forKey: key) {
            return cached
        }
        let (data, _) = try await session.data(from: url)
        cache.store(data, forKey: key, ttl: ttl)
        return data
    }
}
