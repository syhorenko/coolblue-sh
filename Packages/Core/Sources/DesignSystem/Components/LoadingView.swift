//
//  LoadingView.swift
//  Core
//
//  Created by Serhii Horenko on 16/09/2026.
//

import SwiftUI

/// The app's single full-screen busy state.
public struct LoadingView: View {
    private let message: String

    public init(message: String) {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: Spacing.medium) {
            ProgressView()

            Text(message)
                .font(Typography.body)
                .foregroundStyle(Palette.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // One announcement instead of two, so VoiceOver says "Loading products", not
        // "progress indicator" followed by the label.
        .accessibilityElement(children: .combine)
    }
}
