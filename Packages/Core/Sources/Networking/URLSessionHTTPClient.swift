//
//  URLSessionHTTPClient.swift
//  Core
//
//  Created by Serhii Horenko on 16/09/2026.
//

import Foundation

/// The only `HTTPClient` that touches the network.
///
/// A struct, not a class: it holds one immutable `URLSession`, so there is nothing to
/// synchronise and `Sendable` conformance is free. The session is injected rather than
/// created here, which is what lets the tests stub transport with a `URLProtocol`.
public struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    public init(session: URLSession) {
        self.session = session
    }

    public func send(_ request: HTTPRequest) async throws(HTTPError) -> HTTPResponse {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: Self.urlRequest(for: request))
        } catch {
            // Every URLSession failure — offline, DNS, timeout, cancellation — is the
            // same fact to the caller: the answer never arrived.
            throw .connectivity
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw .connectivity
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw .unacceptableStatusCode(httpResponse.statusCode)
        }

        return HTTPResponse(statusCode: httpResponse.statusCode, body: data)
    }

    private static func urlRequest(for request: HTTPRequest) -> URLRequest {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue

        for (field, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: field)
        }

        return urlRequest
    }
}
