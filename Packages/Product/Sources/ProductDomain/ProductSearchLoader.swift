//
//  ProductSearchLoader.swift
//  Product
//
//  Created by Serhii Horenko on 16/09/2026.
//

public protocol ProductSearchLoader: Sendable {
    func search(query: String) async throws(ProductSearchError) -> ProductPage
}
