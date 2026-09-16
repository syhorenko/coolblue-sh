//
//  HTTPClient.swift
//  Core
//
//  Created by Serhii Horenko on 16/09/2026.
//

import Foundation

/// The transport seam every network call in the app goes through.
///
/// Declared in the layer that owns HTTP so feature Data layers depend on this protocol
/// rather than on `URLSession`: tests inject a spy, the app injects
/// `URLSessionHTTPClient` from its composition root, and neither choice is visible to
/// the layers above.
///
/// The typed `throws(HTTPError)` is the point of the abstraction — a conformance cannot
/// smuggle an implementation-specific error out through this boundary.
public protocol HTTPClient: Sendable {
    func send(_ request: HTTPRequest) async throws(HTTPError) -> HTTPResponse
}
