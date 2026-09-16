//
//  ProductPage.swift
//  Product
//
//  Created by Serhii Horenko on 16/09/2026.
//

public struct ProductPage: Equatable, Sendable {
    public let products: [Product]
    public let currentPage: Int
    public let pageCount: Int
    public let totalResults: Int

    public init(products: [Product], currentPage: Int, pageCount: Int, totalResults: Int) {
        self.products = products
        self.currentPage = currentPage
        self.pageCount = pageCount
        self.totalResults = totalResults
    }
}
