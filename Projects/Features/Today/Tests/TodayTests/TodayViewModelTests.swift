//
//  TodayViewModelTests.swift
//  TodayTests
//
//  Created by groot on 7/29/26.
//

import Testing
import Foundation
@testable import Today

@MainActor
@Suite("TodayViewModel")
struct TodayViewModelTests {

    private func viewModel(_ repo: MockTodayRepository) -> TodayViewModel {
        TodayViewModel(useCase: DefaultLoadTodayFeedUseCase(repository: repo))
    }

    @Test("초기 상태는 loading")
    func initialLoading() {
        let repo = MockTodayRepository(curation: [], summaries: .success([]))
        if case .loading = viewModel(repo).state {} else {
            Issue.record("expected loading")
        }
    }

    @Test("성공 시 loaded 로 전이")
    func transitionsToLoaded() async {
        let repo = MockTodayRepository(
            curation: [TestSupport.story(id: "a", appIDs: [1])],
            summaries: .success([TestSupport.summary(id: 1)])
        )
        let vm = viewModel(repo)
        await vm.load()
        if case let .loaded(cards) = vm.state {
            #expect(cards.count == 1)
        } else {
            Issue.record("expected loaded, got \(vm.state)")
        }
    }

    @Test("실패 시 failed 로 전이")
    func transitionsToFailed() async {
        let repo = MockTodayRepository(
            curation: [TestSupport.story(id: "a", appIDs: [1])],
            summaries: .failure
        )
        let vm = viewModel(repo)
        await vm.load()
        if case .failed = vm.state {} else {
            Issue.record("expected failed, got \(vm.state)")
        }
    }

    @Test("refresh 실패 시 기존 loaded 카드 유지")
    func refreshKeepsExistingOnFailure() async {
        // 첫 호출(load) 성공 → 두 번째 호출(refresh) 실패.
        let repo = MockTodayRepository(
            curation: [TestSupport.story(id: "a", appIDs: [1])],
            summariesQueue: [.success([TestSupport.summary(id: 1)]), .failure]
        )
        let vm = viewModel(repo)
        await vm.load()
        await vm.refresh()
        if case let .loaded(cards) = vm.state {
            #expect(cards.count == 1)
        } else {
            Issue.record("expected loaded after refresh, got \(vm.state)")
        }
    }
}
