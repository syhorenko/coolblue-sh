//
//  ProductSearchView.swift
//  Product
//
//  Created by Serhii Horenko on 16/09/2026.
//

import DesignSystem
import ProductPresentation
import SwiftUI

public struct ProductSearchView: View {
    @State private var viewModel: ProductSearchViewModel

    public init(viewModel: ProductSearchViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Coolblue")
                .task { await load() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            LoadingView(message: "Looking for products…")

        case let .loaded(products):
            List(products) { product in
                ProductRow(product: product)
            }
            .listStyle(.plain)

        case .empty:
            EmptyStateView(
                title: "No products",
                message: "The shop has nothing to show right now."
            )

        case let .failed(message, isRetryable):
            ErrorStateView(
                title: "Something went wrong",
                message: message,
                retry: isRetryable ? { Task { await load() } } : nil
            )
        }
    }

    private func load() async {
        await viewModel.search("")
    }
}

#Preview("Loaded") {
    ProductSearchView(viewModel: ProductSearchViewModel(loader: PreviewSearchLoader(.products)))
}

#Preview("Empty") {
    ProductSearchView(viewModel: ProductSearchViewModel(loader: PreviewSearchLoader(.empty)))
}

#Preview("Failed") {
    ProductSearchView(viewModel: ProductSearchViewModel(loader: PreviewSearchLoader(.failure)))
}
