//
//  AppsCuration.swift
//  Apps
//
//  Created by groot on 7/29/26.
//

import Foundation

/// `featured_apps.json` 디코딩 구조.
struct AppsCurationFile: Decodable {
    struct Entry: Decodable {
        let id: Int
        let tagline: String
    }
    let featured: [Entry]
}

/// 정적 큐레이션/카테고리 제공(번들 JSON + 하드코딩 카테고리).
enum AppsCuration {
    /// `featured_apps.json` 로드. 실패 시 빈 배열(추천 섹션 숨김).
    static func featured(bundle: Bundle) -> [FeaturedCuration] {
        guard let url = bundle.url(forResource: "featured_apps", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(AppsCurationFile.self, from: data) else {
            return []
        }
        return file.featured.map { FeaturedCuration(id: $0.id, tagline: $0.tagline) }
    }

    /// 카테고리 그리드 정적 목록(genreID/이름/SF Symbol).
    static let categories: [Category] = [
        Category(genreID: 6014, name: "게임", symbol: "gamecontroller"),
        Category(genreID: 6007, name: "생산성", symbol: "chart.line.uptrend.xyaxis"),
        Category(genreID: 6008, name: "사진 및 비디오", symbol: "camera"),
        Category(genreID: 6015, name: "금융", symbol: "wonsign.circle"),
        Category(genreID: 6023, name: "교육", symbol: "graduationcap"),
        Category(genreID: 6012, name: "라이프스타일", symbol: "leaf"),
        Category(genreID: 6005, name: "소셜 네트워킹", symbol: "person.2"),
        Category(genreID: 6002, name: "유틸리티", symbol: "wrench.and.screwdriver"),
    ]
}
