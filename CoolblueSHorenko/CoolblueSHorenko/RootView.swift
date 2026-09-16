//
//  RootView.swift
//  CoolblueSHorenko
//
//  Created by Serhii Horenko on 16/09/2026.
//

import DesignSystem
import SwiftUI

/// Temporary root.
///
/// It exists so the app target has a screen while the product search feature is built,
/// and so this step is verifiable end to end: if it renders, the app really does link
/// and resolve `DesignSystem` (and, through it, Kingfisher). Replaced by
/// `ProductSearchComposer.makeSearchScreen(environment:)` in the next step, at which
/// point this file is deleted.
struct RootView: View {
    let environment: AppEnvironment

    var body: some View {
        EmptyStateView(
            title: "Coolblue",
            message: "Product search lands here next."
        )
    }
}

#Preview {
    RootView(environment: .live())
}
