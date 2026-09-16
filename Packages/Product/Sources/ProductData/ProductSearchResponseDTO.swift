//
//  ProductSearchResponseDTO.swift
//  Product
//
//  Created by Serhii Horenko on 16/09/2026.
//

import Foundation
import ProductDomain

struct ProductSearchResponseDTO: Decodable {
    let products: [ProductDTO]
    let currentPage: Int
    let pageCount: Int
    let totalResults: Int

    struct ProductDTO: Decodable {
        let productId: Int
        let productName: String
        let productImage: String?
        let salesPriceIncVat: Decimal
        let availabilityState: Int
        let reviewInformation: ReviewInformationDTO?

        struct ReviewInformationDTO: Decodable {
            let reviewSummary: ReviewSummaryDTO?

            struct ReviewSummaryDTO: Decodable {
                let reviewAverage: Double
                let reviewCount: Int
            }
        }
    }
}

// MARK: - Mapping to the domain

extension ProductSearchResponseDTO {
    var page: ProductPage {
        ProductPage(
            products: products.map(\.product),
            currentPage: currentPage,
            pageCount: pageCount,
            totalResults: totalResults
        )
    }
}

extension ProductSearchResponseDTO.ProductDTO {
    var product: Product {
        Product(
            id: productId,
            name: productName,
            price: salesPriceIncVat,
            imageURL: productImage.flatMap(URL.init(string:)),
            rating: reviewInformation?.reviewSummary?.rating,
            availability: Product.Availability(state: availabilityState)
        )
    }
}

extension ProductSearchResponseDTO.ProductDTO.ReviewInformationDTO.ReviewSummaryDTO {
    var rating: Product.Rating? {
        guard reviewCount > 0 else {
            return nil
        }

        return Product.Rating(average: reviewAverage, count: reviewCount)
    }
}

extension Product.Availability {
    init(state: Int) {
        self = state == 2 ? .inStock : .unavailable
    }
}
