//
//  DefaultAppDetailRepository.swift
//  AppDetail
//
//  Created by groot on 7/29/26.
//

import Foundation
import CoreKit
import ITunesKit
import Persistence

/// `AppDetailRepository` 기본 구현. Cache 우선 조회 → miss 시 Lookup → DTO 를 캐시에 저장.
///
/// 캐시에는 상세 DTO 를 JSON `Data` 로 저장한다(TTL 은 Cache 기본).
public struct DefaultAppDetailRepository: AppDetailRepository {
    private let client: ITunesClient
    private let cache: Cache

    public init(client: ITunesClient, cache: Cache) {
        self.client = client
        self.cache = cache
    }

    public func fetch(appID: Int) async throws -> AppDetail {
        let key = Self.cacheKey(appID: appID)

        if let cached = await cache.data(forKey: key) {
            if let dto = try? JSONDecoder().decode(AppDetailCacheDTO.self, from: cached) {
                return AppDetailMapper.map(dto)
            }
            // 손상된 캐시(디코드 실패)는 제거하고 네트워크로 폴백한다.
            await cache.removeValue(forKey: key)
        }

        let dtos = try await client.lookup(ids: [appID])
        guard let dto = dtos.first else { throw CoreError.notFound }

        let cacheDTO = AppDetailCacheDTO(dto)
        if let encoded = try? JSONEncoder().encode(cacheDTO) {
            await cache.store(encoded, forKey: key)
        }
        return AppDetailMapper.map(cacheDTO)
    }

    private static func cacheKey(appID: Int) -> String {
        "appdetail.lookup.\(appID)"
    }
}
