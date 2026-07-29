import Foundation
import CoreKit

/// 이미지 로딩 추상화(DesignSystem 이 주입받아 사용). M1 에서 구현.
public protocol ImageLoading: Sendable {
    /// URL 이미지 원본 데이터를 로드한다.
    func loadImageData(from url: URL) async throws -> Data
}

/// 최근 검색어 저장소(UserDefaults 기반 예정, Search 피처가 사용). M1 에서 구현.
public protocol RecentSearchStore: Sendable {
    func recentTerms() -> [String]
    func add(term: String)
}
