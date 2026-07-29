//
//  CacheTests.swift
//  PersistenceTests
//
//  Created by groot on 7/29/26.
//

import Testing
import Foundation
@testable import Persistence

@Suite("DefaultCache TTL")
struct CacheTests {

    /// 매 테스트 격리 디렉터리.
    private func makeCache(defaultTTL: TimeInterval = 3600) -> (DefaultCache, URL) {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("cachetest-\(UUID().uuidString)", isDirectory: true)
        let cache = DefaultCache(name: "test", defaultTTL: defaultTTL, directory: dir)
        return (cache, dir)
    }

    @Test("저장 후 즉시 조회 성공")
    func storeAndFetch() {
        let (cache, _) = makeCache()
        let data = Data("hello".utf8)
        cache.store(data, forKey: "k", ttl: 60)
        #expect(cache.data(forKey: "k") == data)
    }

    @Test("TTL 만료 후 nil")
    func expires() {
        let (cache, _) = makeCache()
        cache.store(Data("x".utf8), forKey: "k", ttl: -1) // 이미 만료
        #expect(cache.data(forKey: "k") == nil)
    }

    @Test("미저장 키는 nil")
    func miss() {
        let (cache, _) = makeCache()
        #expect(cache.data(forKey: "none") == nil)
    }

    @Test("removeValue 후 nil")
    func remove() {
        let (cache, _) = makeCache()
        cache.store(Data("x".utf8), forKey: "k", ttl: 60)
        cache.removeValue(forKey: "k")
        #expect(cache.data(forKey: "k") == nil)
    }

    @Test("removeAll 후 전부 nil")
    func removeAll() {
        let (cache, _) = makeCache()
        cache.store(Data("a".utf8), forKey: "a", ttl: 60)
        cache.store(Data("b".utf8), forKey: "b", ttl: 60)
        cache.removeAll()
        #expect(cache.data(forKey: "a") == nil)
        #expect(cache.data(forKey: "b") == nil)
    }

    @Test("디스크 지속성: 새 인스턴스에서 조회")
    func diskPersistence() {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("cachetest-\(UUID().uuidString)", isDirectory: true)
        let first = DefaultCache(name: "test", defaultTTL: 3600, directory: dir)
        first.store(Data("persist".utf8), forKey: "k", ttl: 3600)

        let second = DefaultCache(name: "test", defaultTTL: 3600, directory: dir)
        #expect(second.data(forKey: "k") == Data("persist".utf8))
    }
}
