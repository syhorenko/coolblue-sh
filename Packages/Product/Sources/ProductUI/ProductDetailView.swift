//
//  ProductDetailView.swift
//  Product
//
//  Created by Serhii Horenko on 16/09/2026.
//

import DesignSystem
import ProductDomain
import SwiftUI

struct ProductDetailView: View {
    let product: Product

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.large) {
                RemoteImage(url: product.imageURL)
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)

                Text(product.name)
                    .font(Typography.sectionTitle)
                    .foregroundStyle(Palette.primaryText)
            }
            .padding(Spacing.medium)
        }
    }
}

#Preview("Detail") {
    NavigationStack {
        ProductDetailView(product: PreviewProducts.inStock)
    }
}
