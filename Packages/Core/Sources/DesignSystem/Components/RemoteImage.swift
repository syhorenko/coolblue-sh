//
//  RemoteImage.swift
//  Core
//
//  Created by Serhii Horenko on 16/09/2026.
//

import Kingfisher
import SwiftUI

/// Draws a remote image, with caching, fading and download cancellation handled for us.
///
/// Together with `ImageCacheConfiguration` this is the only file in the codebase that
/// knows Kingfisher exists — it is not a declared dependency of any other module, and
/// the app target never imports it. Swapping libraries, or dropping back to
/// `AsyncImage`, is a change to these two files.
public struct RemoteImage: View {
    private let url: URL?
    private let contentMode: SwiftUI.ContentMode

    public init(url: URL?, contentMode: SwiftUI.ContentMode = .fit) {
        self.url = url
        self.contentMode = contentMode
    }

    public var body: some View {
        KFImage(url)
            // A row scrolled past should not keep holding a download slot.
            .cancelOnDisappear(true)
            .fade(duration: 0.2)
            .placeholder { Palette.surface }
            .resizable()
            .aspectRatio(contentMode: contentMode)
            .accessibilityHidden(true)
    }
}
