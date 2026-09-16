//
//  HTTPClientSpy.swift
//  Product
//
//  Created by Serhii Horenko on 16/09/2026.
//

import Foundation
import Networking

/// Records what the loader asked for and answers with whatever the test decided.
///
/// Lives in this target rather than in `ProductTestSupport`, which deliberately depends
/// on `ProductDomain` alone: a spy for an HTTP protocol has no business being reachable
/// from the presentation tests, where the whole point is that HTTP is invisible.
///
/// An actor because the loader awaits it across a suspension point, and the alternative
/// under strict concurrency is a lock the test has to reason about.
actor HTTPClientSpy: HTTPClient {
    enum Result: Sendable {
        case success(HTTPResponse)
        case failure(HTTPError)
    }

    private let result: Result
    private(set) var requests: [HTTPRequest] = []

    init(result: Result) {
        self.result = result
    }

    /// Convenience for the common case: a 200 carrying this body.
    init(body: Data, statusCode: Int = 200) {
        self.init(result: .success(HTTPResponse(statusCode: statusCode, body: body)))
    }

    func send(_ request: HTTPRequest) async throws(HTTPError) -> HTTPResponse {
        requests.append(request)

        switch result {
        case let .success(response):
            return response
        case let .failure(error):
            throw error
        }
    }
}
