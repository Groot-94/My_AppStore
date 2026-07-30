//
//  DefaultAppDetailRepositoryTests.swift
//  AppDetailTests
//
//  Created by groot on 7/29/26.
//

import Testing
import Foundation
import CoreKit
import ITunesKit
@testable import AppDetail

@Suite("DefaultAppDetailRepository")
struct DefaultAppDetailRepositoryTests {

    private let cacheKey = "appdetail.lookup.42"

    private func cachedData(id: Int, name: String) throws -> Data {
        let json = Data(#"{"trackId": \#(id), "trackName": "\#(name)"}"#.utf8)
        let dto = try JSONDecoder().decode(AppDetailCacheDTO.self, from: json)
        return try JSONEncoder().encode(dto)
    }

    @Test("캐시 히트 시 네트워크 미호출, 캐시 값 반환")
    func cacheHitSkipsNetwork() async throws {
        let seed = [cacheKey: try cachedData(id: 42, name: "Cached App")]
        let cache = MockCache(seed: seed)
        let client = MockITunesClient(lookupResult: [try TestSupport.lookupDTO(id: 42)])
        let repo = DefaultAppDetailRepository(client: client, cache: cache)

        let detail = try await repo.fetch(appID: 42)
        #expect(detail.name == "Cached App")
        #expect(client.lookupCallCount == 0)
        #expect(await cache.readKeys.contains(cacheKey))
        #expect(await cache.storedKeys.isEmpty)
    }

    @Test("캐시 미스 시 Lookup 호출 후 캐시 저장")
    func cacheMissCallsNetworkAndStores() async throws {
        let cache = MockCache()
        let dtoJSON = Data(#"{"trackId": 42, "trackName": "Network App"}"#.utf8)
        let dto = try JSONDecoder().decode(ITunesAppDTO.self, from: dtoJSON)
        let client = MockITunesClient(lookupResult: [dto])
        let repo = DefaultAppDetailRepository(client: client, cache: cache)

        let detail = try await repo.fetch(appID: 42)
        #expect(detail.name == "Network App")
        #expect(client.lookupCallCount == 1)
        #expect(client.lookupIDs == [42])
        #expect(await cache.storedKeys == [cacheKey])
    }

    @Test("저장 후 재조회는 캐시 히트(네트워크 1회만)")
    func secondFetchHitsCache() async throws {
        let cache = MockCache()
        let dto = try TestSupport.lookupDTO(id: 42)
        let client = MockITunesClient(lookupResult: [dto])
        let repo = DefaultAppDetailRepository(client: client, cache: cache)

        _ = try await repo.fetch(appID: 42)
        _ = try await repo.fetch(appID: 42)
        #expect(client.lookupCallCount == 1)
    }

    @Test("손상 캐시(디코드 실패)는 제거 후 네트워크 폴백")
    func corruptedCacheIsRemovedAndFallsBack() async throws {
        let seed = [cacheKey: Data("not-json".utf8)]
        let cache = MockCache(seed: seed)
        let dto = try TestSupport.lookupDTO(id: 42)
        let client = MockITunesClient(lookupResult: [dto])
        let repo = DefaultAppDetailRepository(client: client, cache: cache)

        let detail = try await repo.fetch(appID: 42)
        #expect(detail.name == "App 42")
        #expect(await cache.removedKeys == [cacheKey])
        #expect(client.lookupCallCount == 1)
        #expect(await cache.storedKeys == [cacheKey])
    }

    @Test("Lookup 결과 0건이면 notFound")
    func emptyLookupThrowsNotFound() async {
        let cache = MockCache()
        let client = MockITunesClient(lookupResult: [])
        let repo = DefaultAppDetailRepository(client: client, cache: cache)

        await #expect(throws: CoreError.self) {
            _ = try await repo.fetch(appID: 42)
        }
    }
}
