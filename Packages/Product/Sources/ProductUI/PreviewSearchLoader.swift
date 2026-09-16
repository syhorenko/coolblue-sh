//
//  PreviewSearchLoader.swift
//  Product
//
//  Created by Serhii Horenko on 16/09/2026.
//

#if DEBUG
import ProductDomain

/// Feeds the previews a fixed answer, so each state can be looked at without a network.
struct PreviewSearchLoader: ProductSearchLoader {
    enum Outcome {
        case products
        case empty
        case failure
    }

    private let outcome: Outcome

    init(_ outcome: Outcome) {
        self.outcome = outcome
    }

    func search(query: String) async throws(ProductSearchError) -> ProductPage {
        switch outcome {
        case .products:
            return page(with: PreviewProducts.all)
        case .empty:
            return page(with: [])
        case .failure:
            throw .connectivity
        }
    }

    private func page(with products: [Product]) -> ProductPage {
        ProductPage(
            products: products,
            currentPage: 1,
            pageCount: 1,
            totalResults: products.count
        )
    }
}
#endif
