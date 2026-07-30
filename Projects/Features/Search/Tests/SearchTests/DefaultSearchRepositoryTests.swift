//
//  DefaultSearchRepositoryTests.swift
//  SearchTests
//
//  Created by groot on 7/30/26.
//

import Testing
import Foundation
import ITunesKit
@testable import Search

@Suite("DefaultSearchRepository")
struct DefaultSearchRepositoryTests {

    private func loadSearchDTOs() throws -> [ITunesAppDTO] {
        let bundle = Bundle(for: BundleToken.self)
        let url = try #require(bundle.url(forResource: "search", withExtension: "json"))
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(ITunesSearchResponse.self, from: data).results
    }

    @Test("limit 을 그대로 전달하고 앱 검색은 genreID nil")
    func passesLimitAndNilGenre() async throws {
        let client = MockITunesClient(dtos: [])
        let repository = DefaultSearchRepository(client: client)

        _ = try await repository.search(term: "카카오", limit: 25)

        #expect(await client.receivedTerm == "카카오")
        #expect(await client.receivedLimit == 25)
        #expect(await client.receivedGenreID == .some(nil))
    }

    @Test("DTO 를 SearchResultItem 으로 매핑해 반환")
    func mapsDTOsToItems() async throws {
        let dtos = try loadSearchDTOs()
        let client = MockITunesClient(dtos: dtos)
        let repository = DefaultSearchRepository(client: client)

        let items = try await repository.search(term: "카카오", limit: 25)

        #expect(items.count == dtos.count)
        #expect(items.first?.id == 362057947)
    }

    private final class BundleToken {}
}
