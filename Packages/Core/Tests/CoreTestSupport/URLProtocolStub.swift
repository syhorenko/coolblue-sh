//
//  URLProtocolStub.swift
//  Core
//
//  Created by Serhii Horenko on 16/09/2026.
//

import Foundation

/// Intercepts URL loading so `URLSessionHTTPClient` can be tested against a real
/// `URLSession` without a server.
///
/// Registered through a session configuration rather than `URLProtocol.registerClass`,
/// so it only affects sessions built by `makeSession()` and nothing leaks into the rest
/// of the process. The stub itself is still process-wide state, which is why the suites
/// that use it are marked `.serialized`.
public final class URLProtocolStub: URLProtocol {
    public enum Stub: Sendable {
        /// A well-formed HTTP reply.
        case httpResponse(statusCode: Int, body: Data)
        /// A reply that is not an `HTTPURLResponse` — the case a naive client force-casts.
        case nonHTTPResponse(body: Data)
        /// Transport never completed: offline, DNS failure, timeout.
        case failure(NSError)
    }

    private static let lock = NSLock()
    nonisolated(unsafe) private static var stub: Stub?
    nonisolated(unsafe) private static var recorded: [URLRequest] = []

    /// A session that answers from the stub instead of the network.
    public static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return URLSession(configuration: configuration)
    }

    public static func stub(_ stub: Stub) {
        lock.withLock {
            Self.stub = stub
            recorded = []
        }
    }

    public static func reset() {
        lock.withLock {
            stub = nil
            recorded = []
        }
    }

    /// The requests `URLSession` actually sent, in order.
    public static var recordedRequests: [URLRequest] {
        lock.withLock { recorded }
    }

    override public static func canInit(with request: URLRequest) -> Bool {
        lock.withLock { recorded.append(request) }
        return true
    }

    override public static func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override public func startLoading() {
        guard let stub = Self.lock.withLock({ Self.stub }) else {
            client?.urlProtocol(self, didFailWithError: URLError(.unsupportedURL))
            return
        }

        switch stub {
        case let .httpResponse(statusCode, body):
            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: statusCode,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                client?.urlProtocol(self, didFailWithError: URLError(.badURL))
                return
            }

            finish(with: response, body: body)

        case let .nonHTTPResponse(body):
            guard let url = request.url else {
                client?.urlProtocol(self, didFailWithError: URLError(.badURL))
                return
            }

            let response = URLResponse(
                url: url,
                mimeType: nil,
                expectedContentLength: body.count,
                textEncodingName: nil
            )

            finish(with: response, body: body)

        case let .failure(error):
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override public func stopLoading() {
        // Nothing to cancel: every stub completes synchronously in startLoading().
    }

    private func finish(with response: URLResponse, body: Data) {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: body)
        client?.urlProtocolDidFinishLoading(self)
    }
}
