//
//  URLSessionHTTPClientTests.swift
//  Core
//
//  Created by Serhii Horenko on 16/09/2026.
//

import CoreTestSupport
import Foundation
import Networking
import Testing

/// `.serialized` because `URLProtocolStub` is process-wide state; these cases must not
/// interleave. Everything else in the package runs in parallel.
@Suite("URLSessionHTTPClient", .serialized)
struct URLSessionHTTPClientTests {
    @Test("returns body and status code for a 2xx reply")
    func returnsBodyAndStatusCodeOnSuccess() async throws {
        let body = Data("{\"products\":[]}".utf8)
        URLProtocolStub.stub(.httpResponse(statusCode: 200, body: body))
        defer { URLProtocolStub.reset() }

        let response = try await makeSUT().send(anyRequest())

        #expect(response.statusCode == 200)
        #expect(response.body == body)
    }

    @Test("sends the request's method, URL and headers", arguments: [200, 201, 204])
    func sendsTheRequestAsDescribed(statusCode: Int) async throws {
        URLProtocolStub.stub(.httpResponse(statusCode: statusCode, body: Data()))
        defer { URLProtocolStub.reset() }

        let request = HTTPRequest(
            url: try #require(URL(string: "https://any-host.example/search?que=laptop")),
            method: .get,
            headers: ["Accept": "application/json"]
        )

        _ = try await makeSUT().send(request)
        let sent = try #require(URLProtocolStub.recordedRequests.first)

        #expect(sent.url == request.url)
        #expect(sent.httpMethod == "GET")
        #expect(sent.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    @Test("fails with unacceptableStatusCode outside 2xx", arguments: [199, 300, 400, 404, 500])
    func failsOnNonSuccessStatusCode(statusCode: Int) async throws {
        URLProtocolStub.stub(.httpResponse(statusCode: statusCode, body: Data()))
        defer { URLProtocolStub.reset() }

        let sut = makeSUT()
        let request = anyRequest()

        await #expect(throws: HTTPError.unacceptableStatusCode(statusCode)) {
            try await sut.send(request)
        }
    }

    @Test("fails with connectivity when transport fails")
    func failsOnTransportError() async throws {
        URLProtocolStub.stub(.failure(NSError(domain: URLError.errorDomain, code: URLError.notConnectedToInternet.rawValue)))
        defer { URLProtocolStub.reset() }

        let sut = makeSUT()
        let request = anyRequest()

        await #expect(throws: HTTPError.connectivity) {
            try await sut.send(request)
        }
    }

    @Test("fails with connectivity for a reply that is not an HTTP response")
    func failsOnNonHTTPResponse() async throws {
        URLProtocolStub.stub(.nonHTTPResponse(body: Data("anything".utf8)))
        defer { URLProtocolStub.reset() }

        let sut = makeSUT()
        let request = anyRequest()

        await #expect(throws: HTTPError.connectivity) {
            try await sut.send(request)
        }
    }

    // MARK: - Helpers

    private func makeSUT() -> URLSessionHTTPClient {
        URLSessionHTTPClient(session: URLProtocolStub.makeSession())
    }

    private func anyRequest() -> HTTPRequest {
        HTTPRequest(url: URL(fileURLWithPath: "/any").appendingPathExtension("json"))
    }
}
