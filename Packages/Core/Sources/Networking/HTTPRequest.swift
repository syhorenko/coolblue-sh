//
//  HTTPRequest.swift
//  Core
//
//  Created by Serhii Horenko on 16/09/2026.
//

import Foundation

/// A request described as a value, not as a `URLRequest`.
///
/// Feature Data layers build one of these, which keeps them free of URL Loading System
/// types and makes "did we ask for the right thing?" a plain `Equatable` assertion.
public struct HTTPRequest: Equatable, Sendable {
    public enum Method: String, Equatable, Sendable {
        case get = "GET"
    }

    public let url: URL
    public let method: Method
    public let headers: [String: String]

    public init(url: URL, method: Method = .get, headers: [String: String] = [:]) {
        self.url = url
        self.method = method
        self.headers = headers
    }
}

extension HTTPRequest {
    /// Builds a GET request by appending `path` and `query` to `baseURL`.
    ///
    /// `URLComponents` percent-encodes the query, so callers pass raw user input — a
    /// search term with spaces or an apostrophe — without escaping it themselves.
    public static func get(
        baseURL: URL,
        path: String,
        query: [URLQueryItem] = [],
        headers: [String: String] = [:]
    ) throws(HTTPError) -> HTTPRequest {
        let target = path.isEmpty ? baseURL : baseURL.appending(path: path)

        guard var components = URLComponents(url: target, resolvingAgainstBaseURL: false) else {
            throw .invalidURL
        }

        components.queryItems = query.isEmpty ? nil : query

        guard let url = components.url else {
            throw .invalidURL
        }

        return HTTPRequest(url: url, method: .get, headers: headers)
    }
}
