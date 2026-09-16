//
//  ProductSearchViewModelTests.swift
//  Product
//
//  Created by Serhii Horenko on 16/09/2026.
//

import ProductDomain
import ProductTestSupport
import Testing
@testable import ProductPresentation

@Suite("ProductSearchViewModel")
struct ProductSearchViewModelTests {

    // MARK: - Loading

    @Test("shows the loading state before anything has been searched")
    func startsLoading() {
        let viewModel = ProductSearchViewModel(loader: ProductSearchLoaderStub(page: ProductFixtures.searchPage))

        #expect(viewModel.state == .loading)
    }

    @Test("asks the loader nothing until a search is run")
    func doesNotLoadOnInit() {
        let loader = ProductSearchLoaderStub(page: ProductFixtures.searchPage)
        _ = ProductSearchViewModel(loader: loader)

        #expect(loader.recordedQueries.isEmpty)
    }

    @Test("passes the query straight through to the loader")
    func forwardsQuery() async {
        let loader = ProductSearchLoaderStub(page: ProductFixtures.searchPage)
        let viewModel = ProductSearchViewModel(loader: loader)

        await viewModel.search("apple")

        #expect(loader.recordedQueries == ["apple"])
    }

    // MARK: - Results

    @Test("shows the products the loader returned")
    func showsLoadedProducts() async {
        let loader = ProductSearchLoaderStub(page: ProductFixtures.searchPage)
        let viewModel = ProductSearchViewModel(loader: loader)

        await viewModel.search("apple")

        #expect(viewModel.state == .loaded(ProductFixtures.searchPage.products))
    }

    @Test("shows the empty state, not a failure, when nothing matched")
    func showsEmptyState() async {
        let emptyPage = ProductPage(products: [], currentPage: 1, pageCount: 0, totalResults: 0)
        let viewModel = ProductSearchViewModel(loader: ProductSearchLoaderStub(page: emptyPage))

        await viewModel.search("zzzzzz")

        #expect(viewModel.state == .empty)
    }

    // MARK: - Failures

    @Test("offers a retry when the shop could not be reached")
    func showsRetryableFailure() async throws {
        let viewModel = ProductSearchViewModel(loader: ProductSearchLoaderStub(result: .failure(.connectivity)))

        await viewModel.search("apple")

        let failure = try #require(viewModel.state.failure)
        #expect(failure.isRetryable)
        #expect(!failure.message.isEmpty)
    }

    @Test("offers no retry for a reply it will never be able to read")
    func showsNonRetryableFailure() async throws {
        let viewModel = ProductSearchViewModel(loader: ProductSearchLoaderStub(result: .failure(.invalidData)))

        await viewModel.search("apple")

        #expect(try !#require(viewModel.state.failure).isRetryable)
    }

    @Test("recovers when the same search is run again after a failure")
    func recoversOnSecondAttempt() async {
        let loader = ProductSearchLoaderStub(results: [
            .failure(.connectivity),
            .success(ProductFixtures.searchPage)
        ])
        let viewModel = ProductSearchViewModel(loader: loader)

        await viewModel.search("apple")
        #expect(viewModel.state.failure != nil)

        await viewModel.search("apple")

        #expect(viewModel.state == .loaded(ProductFixtures.searchPage.products))
    }

    // MARK: - Cancellation

    @Test("a reply that arrives after its search was abandoned is not published")
    func ignoresStaleReply() async {
        let loader = ProductSearchLoaderStub(page: ProductFixtures.searchPage)
        let viewModel = ProductSearchViewModel(loader: loader)
        let entered = AsyncGate()
        let release = AsyncGate()

        // Park the search inside the loader so it is genuinely in flight when cancelled.
        loader.intercept { _ in
            await entered.open()
            await release.wait()
        }

        let abandoned = Task { await viewModel.search("app") }
        await entered.wait()
        abandoned.cancel()
        await release.open()
        await abandoned.value

        // The loader did run and did answer. The guard after the await is the only
        // reason that answer never reached the screen.
        #expect(loader.recordedQueries == ["app"])
        #expect(viewModel.state == .loading)
    }

    @Test("the newest search wins when an older one is abandoned mid-flight")
    func newestSearchWins() async {
        let stalePage = ProductPage(
            products: [ProductFixtures.makeProduct(id: 1, name: "Stale result")],
            currentPage: 1,
            pageCount: 1,
            totalResults: 1
        )
        let loader = ProductSearchLoaderStub(results: [
            .success(stalePage),
            .success(ProductFixtures.searchPage)
        ])
        let viewModel = ProductSearchViewModel(loader: loader)
        let entered = AsyncGate()
        let release = AsyncGate()

        // "app" is slow: it is still inside the loader when the customer types the "le".
        loader.intercept { query in
            guard query == "app" else {
                return
            }

            await entered.open()
            await release.wait()
        }

        let abandoned = Task { await viewModel.search("app") }
        await entered.wait()
        abandoned.cancel()
        await release.open()
        await abandoned.value

        await viewModel.search("apple")

        #expect(loader.recordedQueries == ["app", "apple"])
        #expect(viewModel.state == .loaded(ProductFixtures.searchPage.products))
    }
}

// MARK: - Reading the failure case out of the state

extension ProductSearchViewState {
    fileprivate var failure: (message: String, isRetryable: Bool)? {
        guard case let .failed(message, isRetryable) = self else {
            return nil
        }

        return (message, isRetryable)
    }
}
