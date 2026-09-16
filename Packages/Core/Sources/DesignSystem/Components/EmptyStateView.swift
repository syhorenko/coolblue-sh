//
//  EmptyStateView.swift
//  Core
//
//  Created by Serhii Horenko on 16/09/2026.
//

import SwiftUI

/// "Nothing to show, and that is not a failure" — no search yet, or no matches.
///
/// Built on `ContentUnavailableView` so it inherits the system's layout, metrics and
/// VoiceOver behaviour rather than reimplementing them.
public struct EmptyStateView: View {
    private let title: String
    private let message: String
    private let systemImage: String

    public init(title: String, message: String, systemImage: String = "magnifyingglass") {
        self.title = title
        self.message = message
        self.systemImage = systemImage
    }

    public var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(message)
        }
    }
}
