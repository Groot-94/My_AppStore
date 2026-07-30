//
//  GamesCurationDataSource.swift
//  Games
//
//  Created by groot on 7/29/26.
//

import Foundation

/// `featured_games.json` 디코딩 구조.
struct GamesCurationFile: Decodable {
    struct Entry: Decodable {
        let id: Int
        let tagline: String
    }
    let featured: [Entry]
}

/// 정적 큐레이션/하위 카테고리 제공(번들 JSON + 하드코딩 카테고리).
enum GamesCurationDataSource {
    static func featured(bundle: Bundle) -> [FeaturedCuration] {
        guard let url = bundle.url(forResource: "featured_games", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(GamesCurationFile.self, from: data) else {
            return []
        }
        return file.featured.map { FeaturedCuration(id: $0.id, tagline: $0.tagline) }
    }

    /// 하위 카테고리 그리드 정적 목록(게임 하위 장르 genreID).
    static let categories: [Category] = [
        Category(genreID: 7001, name: "액션", symbol: "bolt"),
        Category(genreID: 7012, name: "퍼즐", symbol: "puzzlepiece"),
        Category(genreID: 7014, name: "롤플레잉", symbol: "shield"),
        Category(genreID: 7017, name: "전략", symbol: "flag"),
        Category(genreID: 7003, name: "아케이드", symbol: "gamecontroller"),
        Category(genreID: 7002, name: "어드벤처", symbol: "map"),
        Category(genreID: 7009, name: "레이싱", symbol: "car"),
        Category(genreID: 7016, name: "스포츠", symbol: "sportscourt"),
    ]
}
