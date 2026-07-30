//
//  SearchViewModelTests.swift
//  SearchTests
//
//  Created by groot on 7/29/26.
//

import Testing
import Foundation
@testable import Search

@MainActor
@Suite("SearchViewModel")
struct SearchViewModelTests {

    private func makeViewModel(
        outcome: MockSearchRepository.Outcome = .success([]),
        recents: [String] = []
    ) -> (SearchViewModel, MockSearchRepository, MockRecentSearches) {
        let repo = MockSearchRepository(outcome: outcome)
        let recentStore = MockRecentSearches(terms: recents)
        let useCase = DefaultSearchAppsUseCase(repository: repo, recentSearches: recentStore)
        let viewModel = SearchViewModel(useCase: useCase)
        return (viewModel, repo, recentStore)
    }

    @Test("start() 후 idle(최근 검색어) 로드")
    func initialIdleWithRecents() async {
        let (viewModel, _, _) = makeViewModel(recents: ["a", "b"])
        #expect(viewModel.state == .idle([]))   // init 은 동기라 비어 있음
        await viewModel.start()
        #expect(viewModel.state == .idle(["a", "b"]))
    }

    @Test("결과 있으면 loaded 로 전이")
    func transitionsToLoaded() async {
        let items = [TestSupport.item(id: 1)]
        let (viewModel, _, _) = makeViewModel(outcome: .success(items))
        await viewModel.search(term: "kakao")
        #expect(viewModel.state == .loaded(items))
    }

    @Test("결과 0건이면 empty(term)")
    func transitionsToEmpty() async {
        let (viewModel, _, _) = makeViewModel(outcome: .success([]))
        await viewModel.search(term: "xyz")
        #expect(viewModel.state == .empty("xyz"))
    }

    @Test("실패면 failed")
    func transitionsToFailed() async {
        let (viewModel, _, _) = makeViewModel(outcome: .failure)
        await viewModel.search(term: "kakao")
        if case .failed = viewModel.state {} else {
            Issue.record("expected failed, got \(viewModel.state)")
        }
    }

    @Test("빈/공백 검색어는 무시하고 idle 유지")
    func ignoresBlankTerm() async {
        let (viewModel, repo, _) = makeViewModel(recents: ["a"])
        await viewModel.search(term: "   ")
        #expect(viewModel.state == .idle(["a"]))
        #expect(repo.receivedTerms.isEmpty)
    }

    @Test("연속 검색 시 이전 요청 취소 — 최신 결과만 반영")
    func cancelsPreviousSearch() async {
        let (viewModel, repo, _) = makeViewModel()
        // 첫 검색은 지연시켜, 두 번째 검색이 취소하도록 유도.
        repo.set(.delayed([TestSupport.item(id: 99, name: "stale")], 500_000_000))
        let first = Task { await viewModel.search(term: "slow") }

        // 게이트로 첫 요청이 search() 에 실제 진입했음을 보장(스케줄링 무관 결정화).
        await repo.waitForFirstEntry()

        repo.set(.success([TestSupport.item(id: 1, name: "fresh")]))
        await viewModel.search(term: "fast")
        _ = await first.value

        // 두 요청 모두 진입했고(순서 고정), 최신(fast) 결과만 반영, 취소된 stale 은 무시.
        #expect(repo.receivedTerms == ["slow", "fast"])
        #expect(viewModel.state == .loaded([TestSupport.item(id: 1, name: "fresh")]))
    }

    @Test("selectRecent 은 즉시 검색 실행")
    func selectRecentSearches() async {
        let items = [TestSupport.item(id: 7)]
        let (viewModel, repo, _) = makeViewModel(outcome: .success(items))
        await viewModel.selectRecent("지도")
        #expect(repo.receivedTerms == ["지도"])
        #expect(viewModel.state == .loaded(items))
    }

    @Test("clearRecents 는 저장소 비우고 idle([]) 로")
    func clearRecents() async {
        let (viewModel, _, recentStore) = makeViewModel(recents: ["a", "b"])
        await viewModel.clearRecents()
        #expect(await recentStore.clearCallCount == 1)
        #expect(viewModel.state == .idle([]))
    }

    @Test("cancelSearch 는 idle(최근 검색어)로 복귀")
    func cancelReturnsToIdle() async {
        let items = [TestSupport.item(id: 1)]
        let (viewModel, _, recentStore) = makeViewModel(outcome: .success(items), recents: [])
        await viewModel.search(term: "kakao")
        #expect(viewModel.state == .loaded(items))
        // 검색으로 최근 검색어가 저장됐으므로 cancel 시 그 목록으로 idle.
        await viewModel.cancelSearch()
        #expect(viewModel.state == .idle(await recentStore.recentTerms()))
    }

    @Test("retry 는 직전 term 으로 재검색")
    func retryReusesLastTerm() async {
        let (viewModel, repo, _) = makeViewModel(outcome: .failure)
        await viewModel.search(term: "kakao")
        if case .failed = viewModel.state {} else {
            Issue.record("expected failed")
        }
        repo.set(.success([TestSupport.item(id: 1)]))
        await viewModel.retry()
        #expect(repo.receivedTerms == ["kakao", "kakao"])
        #expect(viewModel.state == .loaded([TestSupport.item(id: 1)]))
    }
}
