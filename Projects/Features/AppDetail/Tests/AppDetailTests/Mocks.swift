//
//  Mocks.swift
//  AppDetailTests
//
//  Created by groot on 7/29/26.
//

import Foundation
import CoreKit
import ITunesKit
import Persistence
@testable import AppDetail

/// 결과/에러를 주입할 수 있는 `AppDetailRepository` 목.
final class MockAppDetailRepository: AppDetailRepository, @unchecked Sendable {
    enum Outcome: Sendable {
        case success(AppDetail)
        case notFound
        case failure
    }

    private let lock = NSLock()
    private var _outcome: Outcome
    private(set) var receivedIDs: [Int] = []

    init(outcome: Outcome) {
        self._outcome = outcome
    }

    func fetch(appID: Int) async throws -> AppDetail {
        let outcome: Outcome = lock.withLock {
            receivedIDs.append(appID)
            return _outcome
        }
        switch outcome {
        case let .success(detail): return detail
        case .notFound: throw CoreError.notFound
        case .failure: throw MockError.network
        }
    }
}

/// 저장/조회를 기록하는 `Cache` 목. 초기 저장 데이터를 주입할 수 있다.
final class MockCache: Cache, @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [String: Data]
    private(set) var readKeys: [String] = []
    private(set) var storedKeys: [String] = []

    init(seed: [String: Data] = [:]) {
        self.storage = seed
    }

    func data(forKey key: String) -> Data? {
        lock.withLock {
            readKeys.append(key)
            return storage[key]
        }
    }

    func store(_ data: Data, forKey key: String, ttl: TimeInterval?) {
        lock.withLock {
            storedKeys.append(key)
            storage[key] = data
        }
    }

    func removeValue(forKey key: String) {
        lock.withLock { storage[key] = nil }
    }

    func removeAll() {
        lock.withLock { storage.removeAll() }
    }
}

/// 호출 여부/응답을 제어하는 `ITunesClient` 목(lookup 만 의미 있음).
final class MockITunesClient: ITunesClient, @unchecked Sendable {
    private let lock = NSLock()
    private let lookupResult: [ITunesAppDTO]
    private(set) var lookupCallCount = 0
    private(set) var lookupIDs: [Int] = []

    init(lookupResult: [ITunesAppDTO]) {
        self.lookupResult = lookupResult
    }

    func search(term: String, genreID: Int?, limit: Int) async throws -> [ITunesAppDTO] { [] }

    func lookup(ids: [Int]) async throws -> [ITunesAppDTO] {
        lock.withLock {
            lookupCallCount += 1
            lookupIDs.append(contentsOf: ids)
        }
        return lookupResult
    }

    func chart(_ feed: ChartFeed, limit: Int) async throws -> [RSSEntryDTO] { [] }
}

enum MockError: Error { case network }

/// 테스트용 엔티티 픽스처.
enum TestSupport {
    static func detail(id: Int, name: String = "App", price: String? = nil) -> AppDetail {
        AppDetail(
            id: id,
            name: name,
            sellerName: "Seller",
            genre: "Social Networking",
            iconURL: nil,
            screenshotURLs: [],
            description: "설명",
            releaseNotes: "새 기능",
            version: "1.0",
            updatedAt: nil,
            rating: 4.1,
            ratingCount: 1000,
            price: price,
            contentRating: "4+",
            fileSizeBytes: 1024 * 1024,
            minimumOSVersion: "17.0",
            languages: ["KO"]
        )
    }

    static func lookupDTO(id: Int) throws -> ITunesAppDTO {
        let json = Data(#"{"trackId": \#(id), "trackName": "App \#(id)"}"#.utf8)
        return try JSONDecoder().decode(ITunesAppDTO.self, from: json)
    }
}
