//
//  Cache.swift
//  Persistence
//
//  Created by groot on 7/29/26.
//

import Foundation
import CryptoKit

/// 만료 정책(TTL)이 있는 키-값 캐시(메모리 + 디스크). 값은 `Data` 바이트로 고정.
public protocol Cache: Sendable {
    /// 만료되지 않은 값을 반환. 없거나 만료면 `nil`(만료 항목은 정리).
    func data(forKey key: String) async -> Data?
    /// TTL(초) 과 함께 저장. `ttl` 이 `nil` 이면 기본 TTL 사용.
    func store(_ data: Data, forKey key: String, ttl: TimeInterval?) async
    /// 개별 키 제거.
    func removeValue(forKey key: String) async
    /// 전체 비움(메모리 + 디스크).
    func removeAll() async
}

public extension Cache {
    func store(_ data: Data, forKey key: String) async {
        await store(data, forKey: key, ttl: nil)
    }
}

/// 메모리(NSCache) + 디스크(파일) 2계층 캐시. 접근을 `actor` 격리로 직렬화한다.
public actor DefaultCache: Cache {
    private final class Entry {
        let data: Data
        let expiry: Date
        init(data: Data, expiry: Date) {
            self.data = data
            self.expiry = expiry
        }
    }

    private let memory = NSCache<NSString, Entry>()
    private let directory: URL
    private let defaultTTL: TimeInterval
    private let maxDiskBytes: Int
    private let fileManager = FileManager.default

    /// - Parameters:
    ///   - name: 디스크 하위 폴더명(캐시 네임스페이스).
    ///   - defaultTTL: 기본 만료(초). 기본 1시간.
    ///   - directory: 루트 디렉터리(기본 caches).
    ///   - maxDiskBytes: 스윕 후 디스크 총량 상한(초과 시 오래된 것부터 삭제). 기본 100MB.
    ///   - sweepOnInit: init 시 백그라운드 만료 스윕 수행 여부. 기본 true(테스트는 false 후 직접 호출).
    public init(
        name: String = "AppStoreCache",
        defaultTTL: TimeInterval = 3600,
        directory: URL? = nil,
        maxDiskBytes: Int = 100 * 1024 * 1024,
        sweepOnInit: Bool = true
    ) {
        self.defaultTTL = defaultTTL
        self.maxDiskBytes = maxDiskBytes
        let fileManager = FileManager.default
        let base = directory ?? fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.directory = base.appendingPathComponent(name, isDirectory: true)
        try? fileManager.createDirectory(at: self.directory, withIntermediateDirectories: true)

        // 일회성 키(이미지 URL 등)가 무기한 누적되지 않도록 init 시 1회 스윕.
        // 재조회가 없어도 만료 디스크 항목을 제거하고, 총량 상한을 강제한다.
        if sweepOnInit {
            Task.detached(priority: .utility) { [weak self] in
                await self?.sweepExpired()
            }
        }
    }

    public func data(forKey key: String) -> Data? {
        let now = Date()

        // 1) 메모리
        if let entry = memory.object(forKey: key as NSString) {
            if entry.expiry > now { return entry.data }
            memory.removeObject(forKey: key as NSString)
        }

        // 2) 디스크
        let (fileURL, metaURL) = urls(forKey: key)
        guard
            let expiry = readExpiry(metaURL),
            let data = try? Data(contentsOf: fileURL)
        else {
            return nil
        }
        if expiry <= now {
            try? fileManager.removeItem(at: fileURL)
            try? fileManager.removeItem(at: metaURL)
            return nil
        }
        // 디스크 hit → 메모리 승격
        memory.setObject(Entry(data: data, expiry: expiry), forKey: key as NSString)
        return data
    }

    public func store(_ data: Data, forKey key: String, ttl: TimeInterval?) {
        let expiry = Date().addingTimeInterval(ttl ?? defaultTTL)
        memory.setObject(Entry(data: data, expiry: expiry), forKey: key as NSString)

        let (fileURL, metaURL) = urls(forKey: key)
        try? data.write(to: fileURL, options: .atomic)
        writeExpiry(expiry, to: metaURL)
    }

    public func removeValue(forKey key: String) {
        memory.removeObject(forKey: key as NSString)
        let (fileURL, metaURL) = urls(forKey: key)
        try? fileManager.removeItem(at: fileURL)
        try? fileManager.removeItem(at: metaURL)
    }

    public func removeAll() {
        memory.removeAllObjects()
        try? fileManager.removeItem(at: directory)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    // MARK: - 스윕

    /// 스윕 중 생존 항목의 메타데이터.
    private struct Survivor {
        let base: String
        let expiry: Date
        let size: Int
    }

    /// 디스크 디렉터리를 1회 순회해 만료 항목(.meta 기준)을 삭제하고, 남은 총량이
    /// 상한을 넘으면 오래된(만료 임박) 순으로 추가 삭제한다. init 스윕/테스트가 직접 호출.
    /// 디스크 상태만 정리하며 메모리 캐시는 건드리지 않는다(만료 항목은 조회 시 걸러짐).
    func sweepExpired(now: Date = Date()) {
        guard let names = try? fileManager.contentsOfDirectory(atPath: directory.path) else { return }
        // .meta 를 가진 항목만 유효한 캐시 엔트리로 간주한다.
        let metaNames = names.filter { $0.hasSuffix(".meta") }

        var survivors: [Survivor] = []
        for metaName in metaNames {
            let base = String(metaName.dropLast(".meta".count))
            let fileURL = directory.appendingPathComponent(base, isDirectory: false)
            let metaURL = directory.appendingPathComponent(metaName, isDirectory: false)

            guard let expiry = readExpiry(metaURL) else {
                // 손상된 meta: 짝 파일과 함께 제거.
                try? fileManager.removeItem(at: fileURL)
                try? fileManager.removeItem(at: metaURL)
                continue
            }
            if expiry <= now {
                try? fileManager.removeItem(at: fileURL)
                try? fileManager.removeItem(at: metaURL)
                continue
            }
            let size = ((try? fileManager.attributesOfItem(atPath: fileURL.path))?[.size] as? Int) ?? 0
            survivors.append(Survivor(base: base, expiry: expiry, size: size))
        }

        // 총량 상한 강제: 만료가 가까운(오래 산) 순으로 삭제해 상한 이하로 낮춘다.
        var total = survivors.reduce(0) { $0 + $1.size }
        guard total > maxDiskBytes else { return }
        for entry in survivors.sorted(by: { $0.expiry < $1.expiry }) {
            if total <= maxDiskBytes { break }
            let fileURL = directory.appendingPathComponent(entry.base, isDirectory: false)
            let metaURL = directory.appendingPathComponent("\(entry.base).meta", isDirectory: false)
            try? fileManager.removeItem(at: fileURL)
            try? fileManager.removeItem(at: metaURL)
            total -= entry.size
        }
    }

    // MARK: - 내부

    /// 키를 파일 시스템 안전 이름으로. 실행 간 안정적인 SHA256 해시 사용.
    private func urls(forKey key: String) -> (file: URL, meta: URL) {
        let digest = SHA256.hash(data: Data(key.utf8))
        let safe = digest.map { String(format: "%02x", $0) }.joined()
        let file = directory.appendingPathComponent(safe, isDirectory: false)
        let meta = directory.appendingPathComponent("\(safe).meta", isDirectory: false)
        return (file, meta)
    }

    private func readExpiry(_ metaURL: URL) -> Date? {
        guard
            let raw = try? Data(contentsOf: metaURL),
            let text = String(data: raw, encoding: .utf8),
            let interval = TimeInterval(text)
        else {
            return nil
        }
        return Date(timeIntervalSince1970: interval)
    }

    private func writeExpiry(_ date: Date, to metaURL: URL) {
        let text = String(date.timeIntervalSince1970)
        try? Data(text.utf8).write(to: metaURL, options: .atomic)
    }
}
