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
    func storeAndFetch() async {
        let (cache, _) = makeCache()
        let data = Data("hello".utf8)
        await cache.store(data, forKey: "k", ttl: 60)
        #expect(await cache.data(forKey: "k") == data)
    }

    @Test("TTL 만료 후 nil")
    func expires() async {
        let (cache, _) = makeCache()
        await cache.store(Data("x".utf8), forKey: "k", ttl: -1) // 이미 만료
        #expect(await cache.data(forKey: "k") == nil)
    }

    @Test("미저장 키는 nil")
    func miss() async {
        let (cache, _) = makeCache()
        #expect(await cache.data(forKey: "none") == nil)
    }

    @Test("removeValue 후 nil")
    func remove() async {
        let (cache, _) = makeCache()
        await cache.store(Data("x".utf8), forKey: "k", ttl: 60)
        await cache.removeValue(forKey: "k")
        #expect(await cache.data(forKey: "k") == nil)
    }

    @Test("removeAll 후 전부 nil")
    func removeAll() async {
        let (cache, _) = makeCache()
        await cache.store(Data("a".utf8), forKey: "a", ttl: 60)
        await cache.store(Data("b".utf8), forKey: "b", ttl: 60)
        await cache.removeAll()
        #expect(await cache.data(forKey: "a") == nil)
        #expect(await cache.data(forKey: "b") == nil)
    }

    @Test("디스크 지속성: 새 인스턴스에서 조회")
    func diskPersistence() async {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("cachetest-\(UUID().uuidString)", isDirectory: true)
        let first = DefaultCache(name: "test", defaultTTL: 3600, directory: dir)
        await first.store(Data("persist".utf8), forKey: "k", ttl: 3600)

        let second = DefaultCache(name: "test", defaultTTL: 3600, directory: dir)
        #expect(await second.data(forKey: "k") == Data("persist".utf8))
    }

    // MARK: - 스윕

    /// 스윕 검증용: init 스윕을 끄고 직접 호출해 동기 검증한다.
    /// 반환하는 URL 은 캐시가 실제로 파일을 쓰는 저장 디렉터리(`base/name`)다.
    private func makeManualSweepCache(
        maxDiskBytes: Int = 100 * 1024 * 1024
    ) -> (DefaultCache, URL) {
        let base = FileManager.default.temporaryDirectory
            .appendingPathComponent("cachetest-\(UUID().uuidString)", isDirectory: true)
        let cache = DefaultCache(
            name: "test",
            defaultTTL: 3600,
            directory: base,
            maxDiskBytes: maxDiskBytes,
            sweepOnInit: false
        )
        return (cache, base.appendingPathComponent("test", isDirectory: true))
    }

    /// 디스크에 실제로 남은 캐시 엔트리 수(.meta 기준).
    private func diskEntryCount(_ dir: URL) -> Int {
        let names = (try? FileManager.default.contentsOfDirectory(atPath: dir.path)) ?? []
        return names.filter { $0.hasSuffix(".meta") }.count
    }

    @Test("스윕: 만료 항목만 삭제하고 유효 항목은 유지(재조회 없이)")
    func sweepRemovesExpiredKeepsValid() async {
        let (cache, dir) = makeManualSweepCache()
        await cache.store(Data("valid".utf8), forKey: "valid", ttl: 3600)
        await cache.store(Data("dead".utf8), forKey: "dead", ttl: -1) // 이미 만료
        #expect(diskEntryCount(dir) == 2)

        await cache.sweepExpired()

        #expect(diskEntryCount(dir) == 1)
        #expect(await cache.data(forKey: "valid") == Data("valid".utf8))
        #expect(await cache.data(forKey: "dead") == nil)
    }

    @Test("스윕: 손상된 meta(만료값 없음)는 짝 파일과 함께 제거")
    func sweepRemovesCorruptedMeta() async throws {
        let (cache, dir) = makeManualSweepCache()
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        try Data("garbage".utf8).write(to: dir.appendingPathComponent("abc"))
        try Data("not-a-number".utf8).write(to: dir.appendingPathComponent("abc.meta"))

        await cache.sweepExpired()

        #expect(diskEntryCount(dir) == 0)
        #expect(!FileManager.default.fileExists(atPath: dir.appendingPathComponent("abc").path))
    }

    @Test("스윕: 총량 상한 초과 시 오래된(만료 임박) 것부터 삭제")
    func sweepEnforcesSizeLimit() async {
        // 각 항목 100바이트, 상한 250바이트 → 3개 중 오래된 1개 삭제 후 2개 남김.
        let (cache, dir) = makeManualSweepCache(maxDiskBytes: 250)
        let payload = Data(repeating: 0, count: 100)
        await cache.store(payload, forKey: "old", ttl: 100)    // 가장 먼저 만료 → 우선 삭제 대상
        await cache.store(payload, forKey: "mid", ttl: 200)
        await cache.store(payload, forKey: "new", ttl: 300)
        #expect(diskEntryCount(dir) == 3)

        await cache.sweepExpired()

        #expect(diskEntryCount(dir) == 2)
        // 스윕은 디스크만 정리하므로 메모리에 남은 값이 아니라 디스크 생존을 검증한다.
        // 새 인스턴스(메모리 비어있음)로 같은 디렉터리를 읽어 확인.
        let reopened = DefaultCache(name: "test", defaultTTL: 3600, directory: dir.deletingLastPathComponent(), sweepOnInit: false)
        #expect(await reopened.data(forKey: "old") == nil)
        #expect(await reopened.data(forKey: "new") == payload)
    }
}
