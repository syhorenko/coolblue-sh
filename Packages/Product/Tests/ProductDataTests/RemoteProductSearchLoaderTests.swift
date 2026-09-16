//
//  RemoteProductSearchLoaderTests.swift
//  Product
//
//  Created by Serhii Horenko on 16/09/2026.
//

import Foundation
import Networking
import ProductDomain
import ProductTestSupport
import Testing
@testable import ProductData

@Suite("RemoteProductSearchLoader")
struct RemoteProductSearchLoaderTests {

    // MARK: - The request

    @Test("asks the search endpoint for the given term")
    func buildsSearchRequest() async throws {
        let client = HTTPClientSpy(body: ProductFixtures.emptyPageJSON)
        let loader = makeLoader(client: client)

        _ = try await loader.search(query: "apple")

        let request = try #require(await client.requests.first)
        #expect(await client.requests.count == 1)
        #expect(request.method == .get)
        #expect(
            request.url.absoluteString
                == "https://bdk0sta2n0.execute-api.eu-west-1.amazonaws.com/mobile-assignment/search?que=apple"
        )
    }

    @Test("percent-encodes a term the user could plausibly type")
    func encodesQuery() async throws {
        let client = HTTPClientSpy(body: ProductFixtures.emptyPageJSON)
        let loader = makeLoader(client: client)

        _ = try await loader.search(query: "macbook pro 13\"")

        let request = try #require(await client.requests.first)
        #expect(request.url.query(percentEncoded: false) == "que=macbook pro 13\"")
    }

    @Test("sends nothing until the search is awaited")
    func doesNotRequestOnInit() async {
        let client = HTTPClientSpy(body: ProductFixtures.emptyPageJSON)
        _ = makeLoader(client: client)

        #expect(await client.requests.isEmpty)
    }

    // MARK: - The happy path

    @Test("maps a real payload onto the domain page")
    func mapsSearchPage() async throws {
        let client = HTTPClientSpy(body: ProductFixtures.searchPageJSON)
        let loader = makeLoader(client: client)

        let page = try await loader.search(query: "apple")

        #expect(page == ProductFixtures.searchPage)
    }

    @Test("maps an empty result set to an empty page, not a failure")
    func mapsEmptyPage() async throws {
        let client = HTTPClientSpy(body: ProductFixtures.emptyPageJSON)
        let loader = makeLoader(client: client)

        let page = try await loader.search(query: "zzzzzz")

        #expect(page.products.isEmpty)
        #expect(page.totalResults == 0)
    }

    // MARK: - Failures

    @Test("reports connectivity when the transport fails", arguments: [
        HTTPError.connectivity,
        HTTPError.unacceptableStatusCode(404),
        HTTPError.unacceptableStatusCode(500)
    ])
    func reportsConnectivityOnClientError(clientError: HTTPError) async {
        let client = HTTPClientSpy(result: .failure(clientError))
        let loader = makeLoader(client: client)

        await #expect(throws: ProductSearchError.connectivity) {
            try await loader.search(query: "apple")
        }
    }

    @Test("reports invalidData for a body it cannot read", arguments: [
        Data("not json at all".utf8),
        Data("{}".utf8),
        Data(#"{"products": "unexpected"}"#.utf8),
        Data()
    ])
    func reportsInvalidDataOnUnreadableBody(body: Data) async {
        let client = HTTPClientSpy(body: body)
        let loader = makeLoader(client: client)

        await #expect(throws: ProductSearchError.invalidData) {
            try await loader.search(query: "apple")
        }
    }

    @Test("reports invalidData when a product is missing a field the app renders")
    func reportsInvalidDataOnIncompleteProduct() async {
        let body = Data("""
        {
            "products": [{ "productId": 1, "salesPriceIncVat": 10, "availabilityState": 2 }],
            "currentPage": 1, "pageSize": 24, "totalResults": 1, "pageCount": 1
        }
        """.utf8)
        let loader = makeLoader(client: HTTPClientSpy(body: body))

        await #expect(throws: ProductSearchError.invalidData) {
            try await loader.search(query: "apple")
        }
    }

    // MARK: - Helpers

    /// The real base URL, so the asserted request string is the one the app will send.
    private static let baseURL = URL(
        string: "https://bdk0sta2n0.execute-api.eu-west-1.amazonaws.com/mobile-assignment"
    ) ?? URL(fileURLWithPath: "/")

    private func makeLoader(client: HTTPClient) -> RemoteProductSearchLoader {
        RemoteProductSearchLoader(baseURL: Self.baseURL, client: client)
    }
}
