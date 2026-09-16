//
//  ProductSearchViewModel.swift
//  Product
//
//  Created by Serhii Horenko on 16/09/2026.
//

import Observation
import ProductDomain


@Observable
public final class ProductSearchViewModel {
    public private(set) var state: ProductSearchViewState = .loading

    private let loader: ProductSearchLoader

    public init(loader: ProductSearchLoader) {
        self.loader = loader
    }

    public func search(_ query: String) async {
        state = .loading

        do {
            let page = try await loader.search(query: query)

            guard !Task.isCancelled else {
                return
            }

            state = page.products.isEmpty ? .empty : .loaded(page.products)
        } catch {
            guard !Task.isCancelled else {
                return
            }

            state = Self.state(for: error)
        }
    }

    private static func state(for error: ProductSearchError) -> ProductSearchViewState {
        switch error {
        case .connectivity:
            return .failed(
                message: "We couldn't reach the shop. Check your connection and try again.",
                isRetryable: true
            )
        case .invalidData:

            return .failed(
                message: "Something went wrong at our end. Please try again later.",
                isRetryable: false
            )
        }
    }
}
