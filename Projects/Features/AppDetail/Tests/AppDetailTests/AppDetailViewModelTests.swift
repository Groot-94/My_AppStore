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

    @Test("성공 시 loaded(presentation) 로 전이")
    func transitionsToLoaded() async {
        let now = Date(timeIntervalSince1970: 0)
        let detail = TestSupport.detail(id: 42, name: "카카오톡")
        let repo = MockAppDetailRepository(outcome: .success(detail))
        let useCase = DefaultLoadAppDetailUseCase(repository: repo)
        let viewModel = AppDetailViewModel(appID: 42, useCase: useCase, now: now)
        await viewModel.load()
        #expect(viewModel.state == .loaded(AppDetailPresentation(detail: detail, now: now)))
        #expect(repo.receivedIDs == [42])
    }

    @Test("0건(notFound) 이면 재시도 불가 failed")
    func notFoundIsNotRetryable() async {
        let (viewModel, _) = makeViewModel(outcome: .notFound)
        await viewModel.load()
        if case let .failed(_, retryable) = viewModel.state {
            #expect(retryable == false)
        } else {
            Issue.record("expected failed, got \(viewModel.state)")
        }
    }

    @Test("네트워크 실패면 재시도 가능 failed(본문=네트워크 문구)")
    func networkFailureIsRetryable() async {
        let (viewModel, _) = makeViewModel(outcome: .failure)
        await viewModel.load()
        if case let .failed(message, retryable) = viewModel.state {
            #expect(retryable == true)
            #expect(message == "불러올 수 없습니다. 네트워크를 확인하세요.")
        } else {
            Issue.record("expected failed, got \(viewModel.state)")
        }
    }

    @Test("재시도(load 재호출) 시 다시 요청")
    func retryReloads() async {
        let (viewModel, repo) = makeViewModel(outcome: .failure)
        await viewModel.load()
        await viewModel.load()
        #expect(repo.receivedIDs == [42, 42])
    }

    @Test("실패→retry 성공 시 loaded 로 회복(retryable 리셋)")
    func retryRecoversToLoaded() async {
        let now = Date(timeIntervalSince1970: 0)
        let detail = TestSupport.detail(id: 42, name: "카카오톡")
        let repo = MockAppDetailRepository(outcome: .failure)
        let useCase = DefaultLoadAppDetailUseCase(repository: repo)
        let viewModel = AppDetailViewModel(appID: 42, useCase: useCase, now: now)

        await viewModel.load()
        guard case let .failed(_, retryable) = viewModel.state, retryable else {
            Issue.record("expected retryable failed, got \(viewModel.state)")
            return
        }

        // 네트워크 회복 후 재시도 → loaded 도달, failed 잔여 없음.
        repo.set(.success(detail))
        await viewModel.load()
        #expect(viewModel.state == .loaded(AppDetailPresentation(detail: detail, now: now)))
        #expect(repo.receivedIDs == [42, 42])
    }
}
