//
//  ArcadeMapperTests.swift
//  ArcadeTests
//
//  Created by groot on 7/29/26.
//

import Testing
import Foundation
import ITunesKit
@testable import Arcade

@Suite("ArcadeMapper")
struct ArcadeMapperTests {

    @Test("요청 ID 순서대로 매핑 + 장르/아트워크 채움")
    func mapsInRequestOrder() throws {
        let dtos = try TestSupport.lookupDTOs(named: "lookup")
        let games = ArcadeMapper.games(dtos, ids: [1315612020, 1098342019, 1361926670])

        #expect(games.map(\.id) == [1315612020, 1098342019, 1361926670])
        #expect(games.first?.name == "Grindstone")
        #expect(games.first?.genre == "게임")
        #expect(games.first?.artworkURL != nil)
    }

    @Test("lookup 에 없는 ID 는 제외")
    func skipsMissing() throws {
        let dtos = try TestSupport.lookupDTOs(named: "lookup")
        let games = ArcadeMapper.games(dtos, ids: [1098342019, 999])
        #expect(games.map(\.id) == [1098342019])
    }
}
