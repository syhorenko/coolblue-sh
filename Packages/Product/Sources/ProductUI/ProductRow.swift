//
//  ProductRow.swift
//  Product
//
//  Created by Serhii Horenko on 16/09/2026.
//

import DesignSystem
import ProductDomain
import SwiftUI

struct ProductRow: View {
    let product: Product

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.medium) {
            RemoteImage(url: product.imageURL)
                .frame(width: 72, height: 72)

            VStack(alignment: .leading, spacing: Spacing.xSmall) {
                Text(product.name)
                    .font(Typography.productName)
                    .foregroundStyle(Palette.primaryText)
                    .lineLimit(2)

                if let rating = product.rating {
                    ratingLabel(rating)
                }

                availabilityLabel

                Text(product.price, format: .currency(code: "EUR"))
                    .font(Typography.price)
                    .foregroundStyle(Palette.primaryText)
            }
        }
        .padding(.vertical, Spacing.xSmall)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(ProductSearchAccessibility.row)
    }

    private func ratingLabel(_ rating: Product.Rating) -> some View {
        HStack(spacing: Spacing.xSmall) {
            Image(systemName: "star.fill")
                .foregroundStyle(Palette.accent)

            Text(rating.average, format: .number.precision(.fractionLength(1)))
                .foregroundStyle(Palette.primaryText)

            Text("(\(rating.count.formatted()))")
                .foregroundStyle(Palette.secondaryText)
        }
        .font(Typography.caption)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ratingAccessibilityLabel(rating))
    }

    private func ratingAccessibilityLabel(_ rating: Product.Rating) -> String {
        let average = rating.average.formatted(.number.precision(.fractionLength(1)))

        return "Rated \(average) out of 10, \(rating.count.formatted()) reviews"
    }

    private var availabilityLabel: some View {
        HStack(spacing: Spacing.xSmall) {
            Circle()
                .fill(isInStock ? Palette.available : Palette.unavailable)
                .frame(width: 8, height: 8)

            Text(isInStock ? "In stock" : "Not available")
                .font(Typography.caption)
                .foregroundStyle(Palette.secondaryText)
        }
    }

    private var isInStock: Bool {
        product.availability == .inStock
    }
}

#Preview("Row") {
    List {
        ProductRow(product: PreviewProducts.inStock)
        ProductRow(product: PreviewProducts.unavailable)
        ProductRow(product: PreviewProducts.unrated)
    }
    .listStyle(.plain)
}
