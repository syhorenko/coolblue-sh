//
//  Product.swift
//  Product
//
//  Created by Serhii Horenko on 16/09/2026.
//

import Foundation

public struct Product: Identifiable, Equatable, Sendable {
    public let id: Int
    public let name: String
    public let price: Decimal
    public let imageURL: URL?
    public let rating: Rating?
    public let availability: Availability

    public init(
        id: Int,
        name: String,
        price: Decimal,
        imageURL: URL?,
        rating: Rating?,
        availability: Availability
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.imageURL = imageURL
        self.rating = rating
        self.availability = availability
    }
}

extension Product {

    public struct Rating: Equatable, Sendable {
        public let average: Double
        public let count: Int

        public init(average: Double, count: Int) {
            self.average = average
            self.count = count
        }
    }
    
    public enum Availability: Equatable, Sendable {
        case inStock
        case unavailable
    }
}
