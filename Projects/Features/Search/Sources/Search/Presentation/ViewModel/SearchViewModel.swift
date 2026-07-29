import Foundation
import Observation

/// 검색 화면 ViewModel. UI 프레임워크 비의존(@Observable + @MainActor).
///
/// 상태 전이(docs/05 UI 흐름):
///   idle([recents]) ─Return─▶ loading ─▶ loaded / empty / failed
///   연속 검색 시 이전 Task 취소(최신 요청만 반영).
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
    private let recentSearches: RecentSearching

    /// 진행 중인 검색 Task(연속 검색 시 취소용).
    @ObservationIgnored private var searchTask: Task<Void, Never>?
    /// 재시도용 직전 검색어.
    @ObservationIgnored private var lastTerm: String?

    public init(useCase: SearchAppsUseCase, recentSearches: RecentSearching) {
        self.useCase = useCase
        self.recentSearches = recentSearches
        self.state = .idle(recentSearches.recentTerms())
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
                self.state = .failed("불러올 수 없습니다. 네트워크를 확인하세요.")
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
        recentSearches.clear()
        state = .idle([])
    }

    /// 취소/✕ → 입력·결과 초기화, idle 복귀(최근 검색어 재조회).
    public func cancelSearch() {
        searchTask?.cancel()
        searchTask = nil
        refreshIdle()
    }

    private func refreshIdle() {
        state = .idle(recentSearches.recentTerms())
    }
}
