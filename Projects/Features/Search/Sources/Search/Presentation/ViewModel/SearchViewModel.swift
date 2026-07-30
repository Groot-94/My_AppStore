//
//  SearchViewModel.swift
//  Search
//
//  Created by groot on 7/29/26.
//

import Foundation
import Observation
import CoreKit
import DesignSystem

/// 검색 화면 ViewModel. UI 프레임워크 비의존(@Observable + @MainActor).
///
/// 상태 전이: idle([recents]) → loading → loaded / empty / failed.
/// 연속 검색 시 이전 Task 를 취소해 최신 요청만 반영한다.
@Observable
@MainActor
public final class SearchViewModel {
    public enum State: Sendable, Equatable {
        case idle([String])
        case loading
        case loaded([SearchResultItem])
        case empty(String)
        case failed(String)
    }

    public private(set) var state: State

    private let useCase: SearchAppsUseCase

    /// 진행 중인 검색 Task(연속 검색 시 취소용).
    @ObservationIgnored private var searchTask: Task<Void, Never>?
    /// 재시도용 직전 검색어.
    @ObservationIgnored private var lastTerm: String?

    public init(useCase: SearchAppsUseCase) {
        self.useCase = useCase
        self.state = .idle(useCase.recentTerms())
    }

    /// 검색 실행(Return/검색 버튼). 빈/공백은 무시하고 idle 유지.
    public func search(term: String) async {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            refreshIdle()
            return
        }

        // 연속 검색: 이전 Task 취소 후 최신 요청만 반영.
        searchTask?.cancel()
        lastTerm = trimmed
        state = .loading

        let task = Task { [weak self] in
            guard let self else { return }
            do {
                let items = try await self.useCase.execute(term: trimmed)
                if Task.isCancelled { return }
                if items.isEmpty {
                    self.state = .empty(trimmed)
                } else {
                    self.state = .loaded(items)
                }
            } catch is CancellationError {
                // 취소된 요청은 상태를 건드리지 않는다(최신 요청이 반영됨).
                return
            } catch {
                if Task.isCancelled { return }
                // invalidInput 은 여기 도달하지 않아야 하나(진입 시 공백 차단), 검증 로직이
                // 어긋나도 네트워크 문구로 오표기하지 않도록 empty 로 처리한다.
                if case CoreError.invalidInput = error {
                    self.state = .empty(trimmed)
                } else {
                    self.state = .failed(CommonStrings.Error.networkBody)
                }
            }
        }
        searchTask = task
        await task.value
    }

    /// 최근 검색어 행 탭 → 즉시 검색.
    public func selectRecent(_ term: String) async {
        await search(term: term)
    }

    /// 직전 term 으로 재시도(failed 상태의 [다시 시도]).
    public func retry() async {
        guard let lastTerm else {
            refreshIdle()
            return
        }
        await search(term: lastTerm)
    }

    /// 최근 검색어 비우기 → idle([]).
    public func clearRecents() {
        useCase.clearRecents()
        state = .idle([])
    }

    /// 취소/✕ → 입력·결과 초기화, idle 복귀(최근 검색어 재조회).
    public func cancelSearch() {
        searchTask?.cancel()
        searchTask = nil
        lastTerm = nil
        refreshIdle()
    }

    private func refreshIdle() {
        state = .idle(useCase.recentTerms())
    }
}
