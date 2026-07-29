//
//  ArcadeViewModelTests.swift
//  ArcadeTests
//
//  Created by groot on 7/29/26.
//

import Testing
import Foundation
@testable import Arcade

@MainActor
@Suite("ArcadeViewModel")
struct ArcadeViewModelTests {

    private func viewModel(_ repo: MockArcadeRepository) -> ArcadeViewModel {
        ArcadeViewModel(useCase: DefaultLoadArcadeFeedUseCase(repository: repo))
    }

    @Test("초기 상태는 loading")
    func initialLoading() {
        let repo = MockArcadeRepository(curation: nil)
        if case .loading = viewModel(repo).state {} else {
            Issue.record("expected loading")
        }
    }

    @Test("성공 시 loaded 로 전이")
    func transitionsToLoaded() async {
        let repo = MockArcadeRepository(
            curation: TestSupport.curation(newGameIDs: [1], popularIDs: [2]),
            games: .success([TestSupport.game(id: 1), TestSupport.game(id: 2)])
        )
        let vm = viewModel(repo)
        await vm.load()
        if case let .loaded(feed) = vm.state {
            #expect(feed.newGames.count == 1)
            #expect(feed.popular.count == 1)
        } else {
            Issue.record("expected loaded, got \(vm.state)")
        }
    }

    @Test("빈 큐레이션은 loaded(빈 피드)")
    func emptyCurationLoadsEmptyFeed() async {
        let repo = MockArcadeRepository(
            curation: TestSupport.curation(newGameIDs: [], popularIDs: []),
            games: .success([])
        )
        let vm = viewModel(repo)
        await vm.load()
        if case let .loaded(feed) = vm.state {
            #expect(feed.isEmpty)
        } else {
            Issue.record("expected loaded(empty), got \(vm.state)")
        }
    }

    @Test("큐레이션 없음/실패 시 failed 로 전이")
    func transitionsToFailed() async {
        let repo = MockArcadeRepository(curation: nil)
        let vm = viewModel(repo)
        await vm.load()
        if case .failed = vm.state {} else {
            Issue.record("expected failed, got \(vm.state)")
        }
    }
}
