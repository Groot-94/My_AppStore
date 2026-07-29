import Foundation

/// 최근 검색어 저장 추상화(피처 Domain 소유).
///
/// Domain 이 `Persistence.RecentSearchStore` 를 직접 알지 않도록 프로토콜로 우회한다
/// (docs/02 계층 경계: Domain 은 순수 Swift). Data 폴더의 어댑터가 실제 저장소로 연결한다.
public protocol RecentSearching: Sendable {
    /// 최신순 최근 검색어.
    func recentTerms() -> [String]
    /// 검색어 추가(중복 최상단 갱신, 최대 개수 유지는 구현이 담당).
    func add(term: String)
    /// 전체 비움.
    func clear()
}
