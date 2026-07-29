import Foundation

/// iTunes Search/Lookup 응답 래퍼. 응답 스키마 그대로(화면 개념 없음).
public struct ITunesSearchResponse: Decodable, Sendable {
    public let resultCount: Int
    public let results: [ITunesAppDTO]
}

/// Search/Lookup App 객체 DTO 스텁(docs/04 필드 표). M1 에서 필드 확장.
public struct ITunesAppDTO: Decodable, Sendable {
    public let trackId: Int
    public let trackName: String
}

/// RSS 차트 항목 DTO 스텁.
public struct RSSEntryDTO: Decodable, Sendable {
    public let id: String
    public let name: String
    public let artistName: String
    public let artworkUrl100: String
    public let genres: [RSSGenreDTO]
}

public struct RSSGenreDTO: Decodable, Sendable {
    public let name: String
}
