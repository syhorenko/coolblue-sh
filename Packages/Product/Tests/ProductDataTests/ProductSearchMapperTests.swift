//
//  ProductSearchMapperTests.swift
//  Product
//
//  Created by Serhii Horenko on 16/09/2026.
//

import Foundation
import Networking
import ProductDomain
import Testing
@testable import ProductData

/// Decoding edge cases, asserted against raw bytes.
///
/// Separate from the loader suite because these are questions about the payload, not
/// about fetching it, and routing them through a client would only add ceremony.
@Suite("ProductSearchMapper")
struct ProductSearchMapperTests {

    @Test("keeps a price that a Double would round")
    func preservesDecimalPrice() throws {
        let product = try #require(try map(productJSON(price: "1042.99")).products.first)

        #expect(product.price == Decimal(string: "1042.99"))
    }

    @Test("treats availabilityState 2 as in stock and everything else as unavailable",
          arguments: [(2, Product.Availability.inStock),
                      (3, .unavailable),
                      (0, .unavailable),
                      (99, .unavailable)])
    func mapsAvailabilityState(state: Int, expected: Product.Availability) throws {
        let product = try #require(try map(productJSON(availabilityState: state)).products.first)

        #expect(product.availability == expected)
    }

    @Test("drops a rating nobody has given yet rather than reporting a score of zero")
    func mapsMissingRating() throws {
        let json = productJSON(
            reviewInformation: #"{ "reviews": [], "reviewSummary": { "reviewAverage": 0, "reviewCount": 0 } }"#
        )
        let product = try #require(try map(json).products.first)

        #expect(product.rating == nil)
    }

    @Test("survives a product with no review information at all")
    func mapsAbsentReviewInformation() throws {
        let product = try #require(try map(productJSON()).products.first)

        #expect(product.rating == nil)
    }

    @Test("reads the review average and its sample size")
    func mapsRating() throws {
        let json = productJSON(
            reviewInformation: #"{ "reviews": [], "reviewSummary": { "reviewAverage": 9.2, "reviewCount": 209 } }"#
        )
        let product = try #require(try map(json).products.first)

        #expect(product.rating == Product.Rating(average: 9.2, count: 209))
    }

    @Test("keeps a product whose image URL is unusable instead of failing the page")
    func mapsUnusableImageURL() throws {
        let product = try #require(try map(productJSON(productImage: #""""#)).products.first)

        #expect(product.imageURL == nil)
        #expect(product.name == "A product")
    }

    @Test("keeps a product that ships no image key at all")
    func mapsAbsentImage() throws {
        let product = try #require(try map(productJSON(productImage: nil)).products.first)

        #expect(product.imageURL == nil)
    }

    @Test("ignores keys the app does not read yet")
    func ignoresUnusedKeys() throws {
        let extras = #""USPs": ["one"], "nextDayDelivery": true, "promoIcon": { "text": "x", "type": "action-price" },"#

        #expect(try map(productJSON(extraKeys: extras)).products.count == 1)
    }

    @Test("carries the paging counters through untouched")
    func mapsPagingMetadata() throws {
        let page = try map(ProductFixturesPaging.json)

        #expect(page.currentPage == 3)
        #expect(page.pageCount == 3)
        #expect(page.totalResults == 70)
    }

    // MARK: - Helpers

    private func map(_ json: Data) throws(ProductSearchError) -> ProductPage {
        try ProductSearchMapper.map(HTTPResponse(statusCode: 200, body: json))
    }

    /// One product, assembled from JSON fragments.
    ///
    /// Each optional field is either written once or omitted entirely — an earlier
    /// version appended overrides to a fixed body, which produced duplicate keys that
    /// `JSONDecoder` silently resolved in favour of the first.
    private func productJSON(
        price: String = "10",
        availabilityState: Int = 2,
        productImage: String? = #""https://image.coolblue.nl/300x750/products/1""#,
        reviewInformation: String? = nil,
        extraKeys: String = ""
    ) -> Data {
        let optionalKeys = [
            productImage.map { #""productImage": \#($0),"# },
            reviewInformation.map { #""reviewInformation": \#($0),"# }
        ]
            .compactMap { $0 }
            .joined()

        return Data("""
        {
            "products": [{
                "productId": 1,
                "productName": "A product",
                "salesPriceIncVat": \(price),
                "availabilityState": \(availabilityState),
                \(optionalKeys)
                \(extraKeys)
                "nextDayDelivery": true
            }],
            "currentPage": 1, "pageSize": 24, "totalResults": 1, "pageCount": 1
        }
        """.utf8)
    }
}

/// The paging counters from a real page-3 response, kept beside the case that reads them.
private enum ProductFixturesPaging {
    static let json = Data("""
    {
        "products": [],
        "currentPage": 3,
        "pageSize": 24,
        "totalResults": 70,
        "pageCount": 3
    }
    """.utf8)
}
