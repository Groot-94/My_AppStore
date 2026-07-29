import Foundation

/// 검색 데이터 접근 계약(피처 Domain 소유, 프로토콜만).
///
/// 구현(`DefaultSearchRepository`)은 Data 폴더가 소유하며 Builder 에서 주입한다.
/// Domain 은 ITunesKit/Networking 을 모른다(순수 Swift).
public protocol SearchRepository: Sendable {
    /// 검색어로 앱을 조회해 엔티티 배열을 반환한다.
    /// - Parameter term: 트림된 유효 검색어.
    func search(term: String) async throws -> [SearchResultItem]
}
