//
//  SeeAllViewModelTests.swift
//  SeeAllTests
//
//  Created by groot on 7/29/26.
//

import Testing
import Foundation
import SeeAllInterface
@testable import SeeAll

@MainActor
@Suite("SeeAllViewModel")
struct SeeAllViewModelTests {

    private func makeViewModel(
        outcome: MockChartRepository.Outcome,
        genreID: Int? = nil
    ) -> SeeAllViewModel {
        let repo = MockChartRepository(outcome: outcome)
        let useCase = DefaultLoadChartUseCase(repository: repo)
        let input = SeeAllInput(title: "인기 무료 앱", feed: .topFree, genreID: genreID)
        return SeeAllViewModel(input: input, useCase: useCase)
    }

    @Test("초기 상태는 loading, input 보유")
    func initialLoading() {
        let viewModel = makeViewModel(outcome: .success([]))
        #expect(viewModel.input.title == "인기 무료 앱")
        if case .loading = viewModel.state {} else {
            Issue.record("expected loading, got \(viewModel.state)")
        }
    }

    @Test("성공 시 loaded 로 전이")
    func transitionsToLoaded() async {
        let items = [TestSupport.item(rank: 1, id: 1), TestSupport.item(rank: 2, id: 2)]
        let viewModel = makeViewModel(outcome: .success(items))
        await viewModel.load()
        #expect(viewModel.state == .loaded(items))
    }

    @Test("빈 결과도 loaded([]) 로 전이(안내 문구는 View 위임)")
    func emptyStaysLoaded() async {
        let viewModel = makeViewModel(outcome: .success([]))
        await viewModel.load()
        #expect(viewModel.state == .loaded([]))
    }

    @Test("실패 시 failed 로 전이")
    func transitionsToFailed() async {
        let viewModel = makeViewModel(outcome: .failure)
        await viewModel.load()
        if case .failed = viewModel.state {} else {
            Issue.record("expected failed, got \(viewModel.state)")
        }
    }
}
