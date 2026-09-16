//
//  HTTPError.swift
//  Core
//
//  Created by Serhii Horenko on 16/09/2026.
//

import Foundation

/// Everything that can go wrong at the transport layer, and nothing else.
///
/// `Equatable` so tests can assert on an exact failure instead of "some error", and
/// deliberately free of a wrapped `Error` payload: callers above this layer cannot act on
/// a `URLError` code, so carrying one would only leak detail they must then ignore.
public enum HTTPError: Error, Equatable {
    /// The base URL, path and query could not be combined into a valid URL.
    case invalidURL
    /// The request never reached the server, or the reply was not an HTTP response.
    case connectivity
    /// The server answered, but outside the 2xx range.
    case unacceptableStatusCode(Int)
}
