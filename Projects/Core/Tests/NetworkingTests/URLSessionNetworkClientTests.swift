import Testing
import Foundation
@testable import Networking

@Suite("URLSessionNetworkClient 에러 매핑/재시도")
struct URLSessionNetworkClientTests {
    private let endpoint = Endpoint(host: "example.com", path: "/x")

    @Test("2xx 성공 시 바디 반환")
    func success() async throws {
        let body = Data(#"{"ok":true}"#.utf8)
        let stub = StubHTTPDataFetching(outcomes: [.success(body, statusCode: 200)])
        let client = URLSessionNetworkClient(fetcher: stub, retryPolicy: .none)
        let data = try await client.data(for: endpoint)
        #expect(data == body)
    }

    @Test("비-2xx → unacceptableStatus")
    func statusError() async {
        let stub = StubHTTPDataFetching(outcomes: [.success(Data(), statusCode: 404)])
        let client = URLSessionNetworkClient(fetcher: stub, retryPolicy: .none)
        await #expect(throws: NetworkError.unacceptableStatus(code: 404)) {
            try await client.data(for: endpoint)
        }
    }

    @Test("전송 실패 → transport")
    func transportError() async {
        let stub = StubHTTPDataFetching(outcomes: [.failure(URLError(.notConnectedToInternet))])
        let client = URLSessionNetworkClient(fetcher: stub, retryPolicy: .none)
        await #expect(throws: NetworkError.transport(URLError(.notConnectedToInternet))) {
            try await client.data(for: endpoint)
        }
    }

    @Test("전송 실패는 정책만큼 재시도 후 던짐")
    func retriesTransport() async throws {
        let stub = StubHTTPDataFetching(outcomes: [.failure(URLError(.timedOut))])
        let client = URLSessionNetworkClient(fetcher: stub, retryPolicy: .single)
        await #expect(throws: NetworkError.self) {
            try await client.data(for: endpoint)
        }
        // 최초 1 + 재시도 1 = 2회 호출.
        let calls = await stub.recordedCallCount()
        #expect(calls == 2)
    }

    @Test("재시도 중 성공하면 반환")
    func retryThenSucceed() async throws {
        let body = Data("ok".utf8)
        let stub = StubHTTPDataFetching(outcomes: [
            .failure(URLError(.timedOut)),
            .success(body, statusCode: 200),
        ])
        let client = URLSessionNetworkClient(fetcher: stub, retryPolicy: .single)
        let data = try await client.data(for: endpoint)
        #expect(data == body)
        let calls = await stub.recordedCallCount()
        #expect(calls == 2)
    }

    @Test("상태 에러는 재시도하지 않음")
    func statusNotRetried() async throws {
        let stub = StubHTTPDataFetching(outcomes: [.success(Data(), statusCode: 500)])
        let client = URLSessionNetworkClient(fetcher: stub, retryPolicy: .single)
        await #expect(throws: NetworkError.unacceptableStatus(code: 500)) {
            try await client.data(for: endpoint)
        }
        let calls = await stub.recordedCallCount()
        #expect(calls == 1)
    }

    @Test("decode: 잘못된 JSON → decodingFailed")
    func decodeFailure() async {
        struct Model: Decodable { let value: Int }
        let stub = StubHTTPDataFetching(outcomes: [.success(Data("not json".utf8), statusCode: 200)])
        let client = URLSessionNetworkClient(fetcher: stub, retryPolicy: .none)
        await #expect(throws: NetworkError.decodingFailed) {
            _ = try await client.decode(Model.self, from: endpoint)
        }
    }
}
