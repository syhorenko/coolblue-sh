//
//  Networking.swift
//  Core
//
//  Created by Serhii Horenko on 15/09/2026.
//

// MARK: - Networking (Core)
//
// Feature-agnostic HTTP transport: the HTTPClient protocol, its URLSession-backed
// implementation, request building and response validation. This module knows how to
// perform a request; it does not know what a Product is.
//
// May use: Foundation, URLSession.
// Must not use: any feature type, any DTO, SwiftUI. If a `Product` appears in this
//               module, the transport has stopped being reusable.
//
// Dependencies: none. Runs off the main actor under Swift 6 language mode, so every
// type crossing its boundary must be Sendable.
//
// This file is a placeholder so the target has a source root; delete it once the
// first real type lands here.
