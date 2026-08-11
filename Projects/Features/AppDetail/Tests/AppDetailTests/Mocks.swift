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
actor MockAppDetailRepository: AppDetailRepository {
    enum Outcome: Sendable {
        case success(AppDetail)
        case notFound
        case failure
    }

    private var outcome: Outcome
    private(set) var receivedIDs: [Int] = []

    init(outcome: Outcome) {
        self.outcome = outcome
    }

    func set(_ outcome: Outcome) {
        self.outcome = outcome
    }

    func fetch(appID: Int) async throws -> AppDetail {
        receivedIDs.append(appID)
        switch outcome {
        case let .success(detail): return detail
        case .notFound: throw CoreError.notFound
        case .failure: throw MockError.network
        }
    }
}

/// 저장/조회를 기록하는 `Cache` 목. 초기 저장 데이터를 주입할 수 있다.
actor MockCache: Cache {
    private var storage: [String: Data]
    private(set) var readKeys: [String] = []
    private(set) var storedKeys: [String] = []
    private(set) var removedKeys: [String] = []

    init(seed: [String: Data] = [:]) {
        self.storage = seed
    }

    func data(forKey key: String) -> Data? {
        readKeys.append(key)
        return storage[key]
    }

    func store(_ data: Data, forKey key: String, ttl: TimeInterval?) {
        storedKeys.append(key)
        storage[key] = data
    }

    func removeValue(forKey key: String) {
        removedKeys.append(key)
        storage[key] = nil
    }

    func removeAll() {
        storage.removeAll()
    }
}

/// 호출 여부/응답을 제어하는 `AppLookup` 목.
actor MockITunesClient: AppLookup {
    private let lookupResult: [ITunesAppDTO]
    private(set) var lookupCallCount = 0
    private(set) var lookupIDs: [Int] = []

    init(lookupResult: [ITunesAppDTO]) {
        self.lookupResult = lookupResult
    }

    func lookup(ids: [Int]) async throws -> [ITunesAppDTO] {
        lookupCallCount += 1
        lookupIDs.append(contentsOf: ids)
        return lookupResult
    }
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
