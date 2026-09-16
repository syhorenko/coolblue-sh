//
//  Palette.swift
//  Core
//
//  Created by Serhii Horenko on 16/09/2026.
//

import SwiftUI

/// Colours named by role, never by appearance.
///
/// Only two literal colours exist — the brand pair. Everything else is built from
/// SwiftUI's semantic colours, which already adapt to light and dark mode and to
/// increased-contrast settings, so there is no second palette to keep in sync.
///
/// There is deliberately no `background` token: the screens use SwiftUI's default
/// grouped background, and a hardcoded one would fight it.
public enum Palette {
    /// Coolblue orange. Prices and primary actions only — it must stay rare to stay loud.
    public static let accent = Color(red: 1.0, green: 0.44, blue: 0.0)
    /// Coolblue blue. Navigation and links.
    public static let brand = Color(red: 0.0, green: 0.45, blue: 0.82)

    public static let primaryText = Color.primary
    public static let secondaryText = Color.secondary
    public static let surface = Color.gray.opacity(0.12)
    public static let separator = Color.gray.opacity(0.3)
}
