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
    func data(forKey key: String) -> Data?
    /// TTL(초) 과 함께 저장. `ttl` 이 `nil` 이면 기본 TTL 사용.
    func store(_ data: Data, forKey key: String, ttl: TimeInterval?)
    /// 개별 키 제거.
    func removeValue(forKey key: String)
    /// 전체 비움(메모리 + 디스크).
    func removeAll()
}

public extension Cache {
    func store(_ data: Data, forKey key: String) {
        store(data, forKey: key, ttl: nil)
    }
}

/// 메모리(NSCache) + 디스크(파일) 2계층 캐시. 디스크 접근을 `NSLock` 으로 보호.
public final class DefaultCache: Cache, @unchecked Sendable {
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
    private let fileManager = FileManager.default
    private let lock = NSLock()

    /// - Parameters:
    ///   - name: 디스크 하위 폴더명(캐시 네임스페이스).
    ///   - defaultTTL: 기본 만료(초). 기본 1시간.
    ///   - directory: 루트 디렉터리(기본 caches).
    public init(
        name: String = "AppStoreCache",
        defaultTTL: TimeInterval = 3600,
        directory: URL? = nil
    ) {
        self.defaultTTL = defaultTTL
        let base = directory ?? fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.directory = base.appendingPathComponent(name, isDirectory: true)
        try? fileManager.createDirectory(at: self.directory, withIntermediateDirectories: true)
    }

    public func data(forKey key: String) -> Data? {
        let now = Date()

        // 1) 메모리
        if let entry = memory.object(forKey: key as NSString) {
            if entry.expiry > now { return entry.data }
            memory.removeObject(forKey: key as NSString)
        }

        // 2) 디스크
        lock.lock()
        defer { lock.unlock() }
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

        lock.lock()
        defer { lock.unlock() }
        let (fileURL, metaURL) = urls(forKey: key)
        try? data.write(to: fileURL, options: .atomic)
        writeExpiry(expiry, to: metaURL)
    }

    public func removeValue(forKey key: String) {
        memory.removeObject(forKey: key as NSString)
        lock.lock()
        defer { lock.unlock() }
        let (fileURL, metaURL) = urls(forKey: key)
        try? fileManager.removeItem(at: fileURL)
        try? fileManager.removeItem(at: metaURL)
    }

    public func removeAll() {
        memory.removeAllObjects()
        lock.lock()
        defer { lock.unlock() }
        try? fileManager.removeItem(at: directory)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
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
