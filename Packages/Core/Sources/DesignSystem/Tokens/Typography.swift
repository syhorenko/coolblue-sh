//
//  Typography.swift
//  Core
//
//  Created by Serhii Horenko on 16/09/2026.
//

import SwiftUI

/// Text styles named by role.
///
/// Every style is derived from a built-in `Font` text style rather than a fixed point
/// size, so the app scales with Dynamic Type for free — including the accessibility
/// sizes — and no view has to opt in.
public enum Typography {
    public static let screenTitle = Font.largeTitle.weight(.bold)
    public static let sectionTitle = Font.title3.weight(.semibold)
    public static let productName = Font.headline
    public static let price = Font.title3.weight(.bold)
    public static let body = Font.subheadline
    public static let caption = Font.caption
}
