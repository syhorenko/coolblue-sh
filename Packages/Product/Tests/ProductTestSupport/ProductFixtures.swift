//
//  ProductFixtures.swift
//  Product
//
//  Created by Serhii Horenko on 16/09/2026.
//

import Foundation
import ProductDomain

/// Payloads and entities shared by the Product test targets.
///
/// The JSON here is copied from a real response rather than trimmed to what the mapper
/// currently reads — including keys nothing parses yet, the promo icon that only some
/// products carry, and the whole-number price next to the 24.99 one. A fixture that is
/// tidier than production traffic passes for the wrong reason.
public enum ProductFixtures {

    /// A two-product page: one plain, one carrying every optional the payload can add.
    public static let searchPageJSON = Data("""
    {
        "products": [
            {
                "productId": 793652,
                "productName": "Apple iPhone X 256GB Zilver",
                "reviewInformation": {
                    "reviews": [],
                    "reviewSummary": {
                        "reviewAverage": 9.2,
                        "reviewCount": 209
                    }
                },
                "USPs": [
                    "256 GB opslagcapaciteit",
                    "5,8 inch Retina HD scherm",
                    "iOS 11"
                ],
                "availabilityState": 2,
                "salesPriceIncVat": 1279,
                "productImage": "https://image.coolblue.nl/300x750/products/984921",
                "nextDayDelivery": true
            },
            {
                "productId": 232406,
                "productName": "Apple iPod / iPhone USB Power Adapter",
                "reviewInformation": {
                    "reviews": [],
                    "reviewSummary": {
                        "reviewAverage": 9,
                        "reviewCount": 36
                    }
                },
                "USPs": [
                    "USB A aansluiting",
                    "1,0 A",
                    "1 USB poort"
                ],
                "availabilityState": 3,
                "salesPriceIncVat": 24.99,
                "listPriceIncVat": 29.99,
                "listPriceExVat": 24.78512,
                "productImage": "https://image.coolblue.nl/300x750/products/679663",
                "coolbluesChoiceInformationTitle": "Apple gebruikers ",
                "promoIcon": {
                    "text": "aanbieding",
                    "type": "action-price"
                },
                "nextDayDelivery": true
            }
        ],
        "currentPage": 3,
        "pageSize": 24,
        "totalResults": 70,
        "pageCount": 3
    }
    """.utf8)

    /// What `searchPageJSON` must map to, written out by hand.
    ///
    /// Spelled literally rather than derived from the JSON, so a mapper that quietly
    /// changes a value has nothing to agree with.
    public static let searchPage = ProductPage(
        products: [
            Product(
                id: 793652,
                name: "Apple iPhone X 256GB Zilver",
                price: 1279,
                imageURL: URL(string: "https://image.coolblue.nl/300x750/products/984921"),
                rating: Product.Rating(average: 9.2, count: 209),
                availability: .inStock
            ),
            Product(
                id: 232406,
                name: "Apple iPod / iPhone USB Power Adapter",
                price: 24.99,
                imageURL: URL(string: "https://image.coolblue.nl/300x750/products/679663"),
                rating: Product.Rating(average: 9, count: 36),
                availability: .unavailable
            )
        ],
        currentPage: 3,
        pageCount: 3,
        totalResults: 70
    )

    /// A page with no results — the shape a query for nonsense returns.
    public static let emptyPageJSON = Data("""
    {
        "products": [],
        "currentPage": 1,
        "pageSize": 24,
        "totalResults": 0,
        "pageCount": 0
    }
    """.utf8)

    /// A `Product` whose every field can be overridden, so a test names only what it is
    /// actually asserting on.
    public static func makeProduct(
        id: Int = 1,
        name: String = "Apple iPhone X 256GB Zilver",
        price: Decimal = 1279,
        imageURL: URL? = URL(string: "https://image.coolblue.nl/300x750/products/984921"),
        rating: Product.Rating? = Product.Rating(average: 9.2, count: 209),
        availability: Product.Availability = .inStock
    ) -> Product {
        Product(
            id: id,
            name: name,
            price: price,
            imageURL: imageURL,
            rating: rating,
            availability: availability
        )
    }
}
