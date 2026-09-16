//
//  ProductSearchMapper.swift
//  Product
//
//  Created by Serhii Horenko on 16/09/2026.
//

import Foundation
import Networking
import ProductDomain

enum ProductSearchMapper {
    static func map(_ response: HTTPResponse) throws(ProductSearchError) -> ProductPage {
        // The status code is already known to be 2xx: HTTPClient rejects everything else,
        // so there is no success check to forget here.
        do {
            return try JSONDecoder().decode(ProductSearchResponseDTO.self, from: response.body).page
        } catch {
            throw .invalidData
        }
    }
}
