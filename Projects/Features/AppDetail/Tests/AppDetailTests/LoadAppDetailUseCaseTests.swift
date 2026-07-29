//
//  LoadAppDetailUseCaseTests.swift
//  AppDetailTests
//
//  Created by groot on 7/29/26.
//

import Testing
import Foundation
import CoreKit
@testable import AppDetail

@Suite("DefaultLoadAppDetailUseCase")
struct LoadAppDetailUseCaseTests {

    @Test("appID 를 Repository 로 전달하고 결과를 반환")
    func passesAppIDAndReturnsResult() async throws {
        let expected = TestSupport.detail(id: 42)
        let repo = MockAppDetailRepository(outcome: .success(expected))
        let useCase = DefaultLoadAppDetailUseCase(repository: repo)

        let result = try await useCase.execute(appID: 42)
        #expect(result == expected)
        #expect(repo.receivedIDs == [42])
    }

    @Test("Repository notFound 전파")
    func propagatesNotFound() async {
        let repo = MockAppDetailRepository(outcome: .notFound)
        let useCase = DefaultLoadAppDetailUseCase(repository: repo)
        await #expect(throws: CoreError.self) {
            _ = try await useCase.execute(appID: 1)
        }
    }

    @Test("Repository 실패 전파")
    func propagatesFailure() async {
        let repo = MockAppDetailRepository(outcome: .failure)
        let useCase = DefaultLoadAppDetailUseCase(repository: repo)
        await #expect(throws: MockError.self) {
            _ = try await useCase.execute(appID: 1)
        }
    }
}
