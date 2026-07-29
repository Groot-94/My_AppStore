//
//  AppsViewModelTests.swift
//  AppsTests
//
//  Created by groot on 7/29/26.
//

import Testing
import Foundation
@testable import Apps

@MainActor
@Suite("AppsViewModel")
struct AppsViewModelTests {

    @Test("초기 상태는 loading")
    func initialLoading() {
        let repo = MockAppsRepository()
        let viewModel = AppsViewModel(useCase: DefaultLoadAppsFeedUseCase(repository: repo))
        if case .loading = viewModel.state {} else {
            Issue.record("expected loading, got \(viewModel.state)")
        }
    }

    @Test("성공 시 loaded 로 전이")
    func transitionsToLoaded() async {
        let repo = MockAppsRepository(
            free: .success([TestSupport.chartItem(rank: 1, id: 1)]),
            featured: .success([TestSupport.featured(id: 2)])
        )
        let viewModel = AppsViewModel(useCase: DefaultLoadAppsFeedUseCase(repository: repo))
        await viewModel.load()
        if case let .loaded(feed) = viewModel.state {
            #expect(feed.topFree.count == 1)
            #expect(feed.featured.count == 1)
        } else {
            Issue.record("expected loaded, got \(viewModel.state)")
        }
    }

    @Test("원격 전부 실패면 failed 로 전이")
    func transitionsToFailed() async {
        let repo = MockAppsRepository(free: .failure, paid: .failure, featured: .failure)
        let viewModel = AppsViewModel(useCase: DefaultLoadAppsFeedUseCase(repository: repo))
        await viewModel.load()
        if case .failed = viewModel.state {} else {
            Issue.record("expected failed, got \(viewModel.state)")
        }
    }
}
