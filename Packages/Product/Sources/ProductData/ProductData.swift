//
//  ProductData.swift
//  Product
//
//  Created by Serhii Horenko on 15/09/2026.
//

// MARK: - ProductData (Product feature)
//
// The only place the API's wire format exists: private Codable DTOs, mappers that turn
// them into ProductDomain entities, and the concrete loaders that conform to
// ProductDomain's protocols. Search, detail and list all map through here.
//
// May use: Foundation, Codable, the Networking transport from Core.
// Must not use: SwiftUI, ProductPresentation, ProductUI. Data flows outward; it never
//               reaches back into the layers that consume it.
//
// Dependencies: ProductDomain, Core/Networking. Off the main actor -- decoding has no
// business on the main thread.
//
// Keep DTOs `private` or `internal`. If a DTO becomes public, the wire format has
// leaked into the rest of the app and renaming a JSON key becomes a breaking change.
//
// This file is a placeholder so the target has a source root; delete it once the
// first real type lands here.
