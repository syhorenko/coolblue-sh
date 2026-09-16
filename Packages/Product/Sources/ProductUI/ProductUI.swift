//
//  ProductUI.swift
//  Product
//
//  Created by Serhii Horenko on 15/09/2026.
//

// MARK: - ProductUI (Product feature)
//
// SwiftUI views for search, list and detail, plus the NavigationStack that hosts them
// and the path state it drives.
//
// May use: SwiftUI, ProductPresentation view models and view state, DesignSystem
//          tokens, and Bundle.module for assets shipped with this target.
// Must not use: ProductData, Networking, URLSession. Neither is a declared dependency,
//               so a view cannot construct its own loader -- destinations that need
//               dependencies are injected from the app target's composition root as a
//               `(Route) -> some View` closure.
//
// Dependencies: ProductPresentation, Core/DesignSystem. @MainActor by default.
//
// This file is a placeholder so the target has a source root; delete it once the
// first real type lands here.
