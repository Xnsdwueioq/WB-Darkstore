import XCTest
import HTTPTypes
import OpenAPIRuntime
import os
@testable import NetworkPackage

final class MockTransport: ClientTransport {
    let handler: @Sendable (HTTPRequest, HTTPBody?, URL, String) async throws -> (HTTPResponse, HTTPBody?)

    init(handler: @escaping @Sendable (HTTPRequest, HTTPBody?, URL, String) async throws -> (HTTPResponse, HTTPBody?)) {
        self.handler = handler
    }

    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        try await handler(request, body, baseURL, operationID)
    }
}

final class ThreadSafeCounter: @unchecked Sendable {
    private let lock = os_unfair_lock_t.allocate(capacity: 1)
    private var _count = 0

    init() {
        lock.initialize(to: os_unfair_lock())
    }

    deinit {
        lock.deallocate()
    }

    func increment() -> Int {
        os_unfair_lock_lock(lock)
        defer { os_unfair_lock_unlock(lock) }
        _count += 1
        return _count
    }

    var count: Int {
        os_unfair_lock_lock(lock)
        defer { os_unfair_lock_unlock(lock) }
        return _count
    }
}

final class NetworkPackageTests: XCTestCase {
    func testTokenProviderCalledOnEachRequest() async throws {
        let counter = ThreadSafeCounter()
        let tokenProvider: @Sendable () -> String? = {
            let num = counter.increment()
            return "token_\(num)"
        }

        let middleware = AuthMiddleware(tokenProvider: tokenProvider)

        let request = HTTPRequest(method: .get, scheme: "https", authority: "example.com", path: "/test")
        let (resp1, _) = try await middleware.intercept(request, body: nil, baseURL: URL(string: "https://example.com")!, operationID: "testOp") { req, body, _ in
            XCTAssertEqual(req.headerFields[.authorization], "Bearer token_1")
            return (HTTPResponse(status: .ok), body)
        }
        XCTAssertEqual(resp1.status, .ok)

        let (resp2, _) = try await middleware.intercept(request, body: nil, baseURL: URL(string: "https://example.com")!, operationID: "testOp") { req, body, _ in
            XCTAssertEqual(req.headerFields[.authorization], "Bearer token_2")
            return (HTTPResponse(status: .ok), body)
        }
        XCTAssertEqual(resp2.status, .ok)

        XCTAssertEqual(counter.count, 2)
    }

    func testNetworkErrorMapping() {
        let httpErr = NetworkError.http(statusCode: 404, message: "Not found")
        XCTAssertEqual(httpErr.localizedDescription, "Not found")

        let defaultHttpErr = NetworkError.http(statusCode: 500, message: nil)
        XCTAssertEqual(defaultHttpErr.localizedDescription, "Ошибка HTTP (500)")

        let transportErr = NetworkError.transport("Connection timed out")
        XCTAssertTrue(transportErr.localizedDescription.contains("Connection timed out"))
    }
}
