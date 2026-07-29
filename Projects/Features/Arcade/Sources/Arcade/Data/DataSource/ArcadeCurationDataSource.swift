//
//  ArcadeCurationDataSource.swift
//  Arcade
//
//  Created by groot on 7/29/26.
//

import Foundation

/// `arcade_apps.json` 디코딩 구조.
struct ArcadeCurationFile: Decodable {
    struct Hero: Decodable {
        let title: String
        let subtitle: String
    }
    let hero: Hero
    let newGames: [Int]
    let popular: [Int]
}

/// 번들 정적 큐레이션 로드. 파싱 실패 시 nil(UseCase 가 notFound 로 처리).
enum ArcadeCurationDataSource {
    static func curation(bundle: Bundle) -> ArcadeCuration? {
        guard let url = bundle.url(forResource: "arcade_apps", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(ArcadeCurationFile.self, from: data) else {
            return nil
        }
        return ArcadeCuration(
            hero: ArcadeHero(title: file.hero.title, subtitle: file.hero.subtitle),
            newGameIDs: file.newGames,
            popularIDs: file.popular
        )
    }
}
