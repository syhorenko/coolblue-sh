//
//  ProductSearchLoaderStub.swift
//  Product
//
//  Created by Serhii Horenko on 16/09/2026.
//

import Foundation
import ProductDomain

/// A `ProductSearchLoader` that answers with whatever the test decided, and remembers
/// what it was asked.
///
/// Lives in `ProductTestSupport` — which depends on `ProductDomain` alone — so the
/// presentation tests can drive a full search without `Networking`, `ProductData` or a
/// single byte of JSON anywhere in the target.
///
/// A lock rather than an actor: `search` has to stay `async throws(ProductSearchError)`
/// to satisfy the protocol, and an actor would add a suspension point the view model's
/// cancellation tests would then have to reason about.
public final class ProductSearchLoaderStub: ProductSearchLoader, @unchecked Sendable {
    public enum Result: Sendable {
        case success(ProductPage)
        case failure(ProductSearchError)
    }

    /// Runs inside `search`, before it answers — the seam a test uses to hold a search
    /// in flight while it cancels the task around it.
    public typealias Interceptor = @Sendable (String) async -> Void

    private let lock = NSLock()
    private var results: [Result]
    private var recorded: [String] = []
    private var interceptor: Interceptor?

    /// Answers each call with the next result, repeating the last one once exhausted.
    public init(results: [Result]) {
        self.results = results
    }

    public convenience init(result: Result) {
        self.init(results: [result])
    }

    /// Convenience for the common case: a page that loads successfully.
    public convenience init(page: ProductPage) {
        self.init(results: [.success(page)])
    }

    /// The queries the loader was actually asked for, in order.
    public var recordedQueries: [String] {
        lock.withLock { recorded }
    }

    /// Installs a hook that runs after the query is recorded and before the result is
    /// returned.
    public func intercept(_ interceptor: @escaping Interceptor) {
        lock.withLock { self.interceptor = interceptor }
    }

    public func search(query: String) async throws(ProductSearchError) -> ProductPage {
        let (result, interceptor): (Result?, Interceptor?) = lock.withLock {
            recorded.append(query)
            return (results.count > 1 ? results.removeFirst() : results.first, self.interceptor)
        }

        await interceptor?(query)

        switch result {
        case let .success(page):
            return page
        case let .failure(error):
            throw error
        case nil:
            // A test that stubs nothing but searches anyway has a gap in its setup; say
            // so through the error channel rather than crashing the suite.
            throw .invalidData
        }
    }
}
