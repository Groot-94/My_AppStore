import Testing
import Foundation
import CoreKit
@testable import Search

@Suite("DefaultSearchAppsUseCase")
struct SearchAppsUseCaseTests {

    private func makeUseCase(
        outcome: MockSearchRepository.Outcome = .success([])
    ) -> (DefaultSearchAppsUseCase, MockSearchRepository, MockRecentSearches) {
        let repo = MockSearchRepository(outcome: outcome)
        let recents = MockRecentSearches()
        let useCase = DefaultSearchAppsUseCase(repository: repo, recentSearches: recents)
        return (useCase, repo, recents)
    }

    @Test("검색어 트림 후 Repository 로 전달")
    func trimsTermBeforeSearch() async throws {
        let (useCase, repo, _) = makeUseCase(outcome: .success([TestSupport.item(id: 1)]))
        _ = try await useCase.execute(term: "  kakao  ")
        #expect(repo.receivedTerms == ["kakao"])
    }

    @Test("빈/공백 검색어는 invalidInput 던지고 Repository 미호출")
    func rejectsBlankTerm() async {
        let (useCase, repo, recents) = makeUseCase()
        await #expect(throws: CoreError.self) {
            _ = try await useCase.execute(term: "   ")
        }
        #expect(repo.receivedTerms.isEmpty)
        #expect(recents.addedTerms.isEmpty)
    }

    @Test("검색 시 최근 검색어 저장 위임(트림된 값)")
    func savesRecentTerm() async throws {
        let (useCase, _, recents) = makeUseCase(outcome: .success([TestSupport.item(id: 1)]))
        _ = try await useCase.execute(term: "  지도 ")
        #expect(recents.addedTerms == ["지도"])
    }

    @Test("Repository 결과를 그대로 반환")
    func returnsRepositoryResults() async throws {
        let expected = [TestSupport.item(id: 1), TestSupport.item(id: 2)]
        let (useCase, _, _) = makeUseCase(outcome: .success(expected))
        let result = try await useCase.execute(term: "kakao")
        #expect(result == expected)
    }

    @Test("Repository 실패는 전파, 최근 검색어는 이미 저장됨")
    func propagatesFailure() async {
        let (useCase, _, recents) = makeUseCase(outcome: .failure)
        await #expect(throws: MockError.self) {
            _ = try await useCase.execute(term: "kakao")
        }
        #expect(recents.addedTerms == ["kakao"])
    }
}
