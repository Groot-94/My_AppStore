//
//  TodayMapperTests.swift
//  TodayTests
//
//  Created by groot on 7/29/26.
//

import Testing
import Foundation
import ITunesKit
@testable import Today

@Suite("TodayMapper")
struct TodayMapperTests {

    @Test("요청 ID 순서대로 매핑 + 아이콘/장르/가격 채움")
    func mapsInRequestOrder() throws {
        let dtos = try TestSupport.lookupDTOs(named: "lookup")
        let summaries = TodayMapper.summaries(dtos, ids: [1018769995, 362057947, 839333328])

        #expect(summaries.map(\.id) == [1018769995, 362057947, 839333328])
        #expect(summaries.first?.name == "당근")
        #expect(summaries.first?.genre == "쇼핑")
        #expect(summaries.first(where: { $0.id == 362057947 })?.iconURL != nil)
        #expect(summaries.allSatisfy { $0.priceText == "받기" })
    }

    @Test("lookup 에 없는 ID 는 제외")
    func skipsMissing() throws {
        let dtos = try TestSupport.lookupDTOs(named: "lookup")
        let summaries = TodayMapper.summaries(dtos, ids: [362057947, 999])
        #expect(summaries.map(\.id) == [362057947])
    }
}
