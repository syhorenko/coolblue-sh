//
//  ProductSearchViewState.swift
//  Product
//
//  Created by Serhii Horenko on 16/09/2026.
//

import ProductDomain

public enum ProductSearchViewState: Equatable, Sendable {
    case loading
    case loaded([Product])
    /// The search succeeded and matched nothing. Not a failure, and not retryable.
    case empty
    case failed(message: String, isRetryable: Bool)
}
