//
//  AppDetailViewModelTests.swift
//  AppDetailTests
//
//  Created by groot on 7/29/26.
//

import Testing
import Foundation
@testable import AppDetail

@MainActor
@Suite("AppDetailViewModel")
struct AppDetailViewModelTests {

    private func makeViewModel(
        outcome: MockAppDetailRepository.Outcome
    ) -> (AppDetailViewModel, MockAppDetailRepository) {
        let repo = MockAppDetailRepository(outcome: outcome)
        let useCase = DefaultLoadAppDetailUseCase(repository: repo)
        let viewModel = AppDetailViewModel(appID: 42, useCase: useCase)
        return (viewModel, repo)
    }

    @Test("초기 상태는 loading, appID 보유")
    func initialLoading() {
        let (viewModel, _) = makeViewModel(outcome: .success(TestSupport.detail(id: 42)))
        #expect(viewModel.appID == 42)
        if case .loading = viewModel.state {} else {
            Issue.record("expected loading, got \(viewModel.state)")
        }
    }

    @Test("성공 시 loaded 로 전이")
    func transitionsToLoaded() async {
        let detail = TestSupport.detail(id: 42, name: "카카오톡")
        let (viewModel, repo) = makeViewModel(outcome: .success(detail))
        await viewModel.load()
        #expect(viewModel.state == .loaded(detail))
        #expect(repo.receivedIDs == [42])
    }

    @Test("0건(notFound) 이면 앱을 찾을 수 없음 + 재시도 불가")
    func notFoundIsNotRetryable() async {
        let (viewModel, _) = makeViewModel(outcome: .notFound)
        await viewModel.load()
        #expect(viewModel.state == .failed("앱을 찾을 수 없음"))
        #expect(viewModel.isRetryable == false)
    }

    @Test("네트워크 실패면 failed + 재시도 가능")
    func networkFailureIsRetryable() async {
        let (viewModel, _) = makeViewModel(outcome: .failure)
        await viewModel.load()
        if case .failed = viewModel.state {} else {
            Issue.record("expected failed, got \(viewModel.state)")
        }
        #expect(viewModel.isRetryable == true)
    }

    @Test("재시도(load 재호출) 시 다시 요청")
    func retryReloads() async {
        let (viewModel, repo) = makeViewModel(outcome: .failure)
        await viewModel.load()
        await viewModel.load()
        #expect(repo.receivedIDs == [42, 42])
    }
}
