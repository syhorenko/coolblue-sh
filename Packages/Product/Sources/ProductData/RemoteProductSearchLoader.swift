//
//  RemoteProductSearchLoader.swift
//  Product
//
//  Created by Serhii Horenko on 16/09/2026.
//

import Foundation
import Networking
import ProductDomain

public struct RemoteProductSearchLoader: ProductSearchLoader {
    private let baseURL: URL
    private let client: HTTPClient

    public init(baseURL: URL, client: HTTPClient) {
        self.baseURL = baseURL
        self.client = client
    }

    public func search(query: String) async throws(ProductSearchError) -> ProductPage {
        let request: HTTPRequest

        do {
            request = try HTTPRequest.get(
                baseURL: baseURL,
                path: "search",
                query: [URLQueryItem(name: "que", value: query)]
            )
        } catch {
            throw .connectivity
        }

        let response: HTTPResponse

        do {
            response = try await client.send(request)
        } catch {
            throw .connectivity
        }

        return try ProductSearchMapper.map(response)
    }
}
