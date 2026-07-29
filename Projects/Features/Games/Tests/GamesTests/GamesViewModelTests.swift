//
//  GamesViewModelTests.swift
//  GamesTests
//
//  Created by groot on 7/29/26.
//

import Testing
import Foundation
@testable import Games

@MainActor
@Suite("GamesViewModel")
struct GamesViewModelTests {

    @Test("초기 상태는 loading")
    func initialLoading() {
        let viewModel = GamesViewModel(useCase: DefaultLoadGamesFeedUseCase(repository: MockGamesRepository()))
        if case .loading = viewModel.state {} else {
            Issue.record("expected loading, got \(viewModel.state)")
        }
    }

    @Test("성공 시 loaded 로 전이")
    func transitionsToLoaded() async {
        let repo = MockGamesRepository(free: .success([TestSupport.chartItem(rank: 1, id: 1)]))
        let viewModel = GamesViewModel(useCase: DefaultLoadGamesFeedUseCase(repository: repo))
        await viewModel.load()
        if case let .loaded(feed) = viewModel.state {
            #expect(feed.topFree.count == 1)
        } else {
            Issue.record("expected loaded, got \(viewModel.state)")
        }
    }

    @Test("원격 전부 실패면 failed 로 전이")
    func transitionsToFailed() async {
        let repo = MockGamesRepository(free: .failure, paid: .failure, featured: .failure)
        let viewModel = GamesViewModel(useCase: DefaultLoadGamesFeedUseCase(repository: repo))
        await viewModel.load()
        if case .failed = viewModel.state {} else {
            Issue.record("expected failed, got \(viewModel.state)")
        }
    }
}
