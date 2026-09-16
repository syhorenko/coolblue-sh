//
//  HTTPRequestTests.swift
//  Core
//
//  Created by Serhii Horenko on 16/09/2026.
//

import Foundation
import Networking
import Testing

@Suite("HTTPRequest")
struct HTTPRequestTests {
    @Test("appends the path to the base URL")
    func appendsPathToBaseURL() throws {
        let request = try HTTPRequest.get(baseURL: baseURL(), path: "search")

        #expect(request.url.absoluteString == "https://any-host.example/mobile-assignment/search")
        #expect(request.method == .get)
    }

    @Test("omits the query string when there are no items")
    func omitsEmptyQueryString() throws {
        let request = try HTTPRequest.get(baseURL: baseURL(), path: "search", query: [])

        #expect(!request.url.absoluteString.contains("?"))
    }

    @Test("appends query items in the order given")
    func appendsQueryItemsInOrder() throws {
        let request = try HTTPRequest.get(
            baseURL: baseURL(),
            path: "search",
            query: [URLQueryItem(name: "que", value: "laptop"), URLQueryItem(name: "page", value: "1")]
        )

        #expect(request.url.query == "que=laptop&page=1")
    }

    @Test("percent-encodes query values so callers never escape user input")
    func percentEncodesQueryValues() throws {
        let request = try HTTPRequest.get(
            baseURL: baseURL(),
            path: "search",
            query: [URLQueryItem(name: "que", value: "de'longhi & co")]
        )

        #expect(request.url.absoluteString.hasSuffix("?que=de'longhi%20%26%20co"))
    }

    @Test("carries the headers it was given")
    func carriesHeaders() throws {
        let request = try HTTPRequest.get(
            baseURL: baseURL(),
            path: "search",
            headers: ["Accept": "application/json"]
        )

        #expect(request.headers == ["Accept": "application/json"])
    }

    // MARK: - Helpers

    private func baseURL() throws -> URL {
        try #require(URL(string: "https://any-host.example/mobile-assignment"))
    }
}
