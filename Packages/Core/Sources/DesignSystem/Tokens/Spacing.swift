//
//  Spacing.swift
//  Core
//
//  Created by Serhii Horenko on 16/09/2026.
//

import SwiftUI

/// The only allowed gaps and paddings.
///
/// Views name a step instead of writing a number, so the whole app's rhythm is one edit
/// and a code review can spot an ad-hoc `padding(13)` immediately.
public enum Spacing {
    public static let xSmall: CGFloat = 4
    public static let small: CGFloat = 8
    public static let medium: CGFloat = 16
    public static let large: CGFloat = 24
    public static let xLarge: CGFloat = 32
}
