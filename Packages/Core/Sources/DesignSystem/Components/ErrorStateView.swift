//
//  ErrorStateView.swift
//  Core
//
//  Created by Serhii Horenko on 16/09/2026.
//

import SwiftUI

/// A failure the user can do something about.
///
/// The retry action is a closure, not a protocol or a delegate: this view renders a
/// message and reports a tap, and has no opinion about what retrying means.
public struct ErrorStateView: View {
    private let title: String
    private let message: String
    private let retryTitle: String
    private let retry: () -> Void

    public init(
        title: String,
        message: String,
        retryTitle: String = "Try again",
        retry: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.retryTitle = retryTitle
        self.retry = retry
    }

    public var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: "wifi.exclamationmark")
        } description: {
            Text(message)
        } actions: {
            Button(retryTitle, action: retry)
                .buttonStyle(.borderedProminent)
                .tint(Palette.brand)
        }
    }
}
