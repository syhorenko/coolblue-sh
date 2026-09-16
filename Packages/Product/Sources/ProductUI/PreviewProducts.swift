//
//  PreviewProducts.swift
//  Product
//
//  Created by Serhii Horenko on 16/09/2026.
//

#if DEBUG
import Foundation
import ProductDomain

nonisolated enum PreviewProducts {
    static let inStock = Product(
        id: 881_732,
        name: "Apple iPhone X 256GB Zilver",
        price: 1279,
        imageURL: URL(string: "https://image.coolblue.nl/300x750/products/1213950"),
        rating: Product.Rating(average: 9.2, count: 209),
        availability: .inStock
    )

    static let unavailable = Product(
        id: 900_213,
        name: "Apple iPhone X Siliconen Back Cover Zwart",
        price: 24.99,
        imageURL: URL(string: "https://image.coolblue.nl/300x750/products/1215085"),
        rating: Product.Rating(average: 7.8, count: 12),
        availability: .unavailable
    )

    static let unrated = Product(
        id: 900_512,
        name: "Apple Lightning naar 3,5 mm Jack Adapter",
        price: 9,
        imageURL: nil,
        rating: nil,
        availability: .inStock
    )

    static let all = [inStock, unavailable, unrated]
}
#endif
