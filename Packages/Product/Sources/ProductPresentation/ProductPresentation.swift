//
//  ProductPresentation.swift
//  Product
//
//  Created by Serhii Horenko on 15/09/2026.
//

// MARK: - ProductPresentation (Product feature)
//
// View models, view state and the formatters that produce display strings. Holds
// ProductDomain's loader protocols -- never a concrete loader. Also declares the
// feature's route type, so navigation intent is testable without a view hierarchy.
//
// May use: Foundation, Observation, ProductDomain types.
// Must not use: URLSession, JSONDecoder, Codable, SwiftUI, ProductData. NavigationPath
//               is a SwiftUI type, so routing state lives in ProductUI; this module
//               only says which routes exist.
//
// Dependencies: ProductDomain. @MainActor by default. Deliberately SwiftUI-free, so a
// view model can be driven by a stub loader and asserted on directly.
//
// This file is a placeholder so the target has a source root; delete it once the
// first real type lands here.
