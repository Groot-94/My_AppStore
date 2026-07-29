//
//  TodayCurationDataSource.swift
//  Today
//
//  Created by groot on 7/29/26.
//

import Foundation

/// `today_curation.json` 디코딩 구조.
struct TodayCurationFile: Decodable {
    struct Story: Decodable {
        let id: String
        let kind: String
        let eyebrow: String
        let title: String
        let subtitle: String
        let appIDs: [Int]
    }
    let stories: [Story]
}

/// 번들 정적 큐레이션 로드. 파싱 실패 시 빈 배열(UseCase 가 notFound 로 처리).
enum TodayCurationDataSource {
    static func stories(bundle: Bundle) -> [TodayStoryCuration] {
        guard let url = bundle.url(forResource: "today_curation", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(TodayCurationFile.self, from: data) else {
            return []
        }
        return file.stories.map { story in
            TodayStoryCuration(
                id: story.id,
                kind: TodayCardKind(rawValue: story.kind) ?? .list,
                eyebrow: story.eyebrow,
                title: story.title,
                subtitle: story.subtitle,
                appIDs: story.appIDs
            )
        }
    }
}
