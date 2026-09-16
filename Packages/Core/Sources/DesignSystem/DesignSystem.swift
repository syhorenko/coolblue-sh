//
//  DesignSystem.swift
//  Core
//
//  Created by Serhii Horenko on 15/09/2026.
//

// MARK: - DesignSystem (Core)
//
// Feature-agnostic visual primitives: spacing scale, colour and typography tokens,
// and small shared views (loading state, error state, async image). Anything a second
// feature would otherwise copy.
//
// May use: SwiftUI, and Bundle.module for colour sets and images shipped with this
//          target.
// Must not use: any feature type. A view here must not know what it is displaying.
//
// Dependencies: none. @MainActor by default.
//
// Note on assets: AppIcon and AccentColor must stay in the app target's asset
// catalogue -- iOS reads those from the app bundle. Everything else belongs here.
//
// This file is a placeholder so the target has a source root; delete it once the
// first real type lands here.
