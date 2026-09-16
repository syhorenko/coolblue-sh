//
//  ImageCacheConfiguration.swift
//  Core
//
//  Created by Serhii Horenko on 16/09/2026.
//

import Kingfisher
import Foundation

/// Image cache policy, applied once at launch by the composition root.
///
/// This lives in the design system rather than the app target for one reason: it keeps
/// `import Kingfisher` on this side of the module boundary. The app calls
/// `ImageCacheConfiguration.apply()` and never links or names the library itself.
public enum ImageCacheConfiguration {
    /// Call once, before the first `RemoteImage` is drawn.
    public static func apply() {
        let cache = ImageCache.default

        // Product thumbnails are small and re-shown constantly while scrolling, so a
        // generous memory cache with a short lifetime beats a large one that goes stale.
        cache.memoryStorage.config.totalCostLimit = 64 * 1024 * 1024
        cache.memoryStorage.config.expiration = .seconds(300)

        // Disk survives relaunches; a week is well inside how often product imagery
        // changes, and the URLs are content-addressed by product id anyway.
        cache.diskStorage.config.sizeLimit = 256 * 1024 * 1024
        cache.diskStorage.config.expiration = .days(7)

        // Matches the HTTP client's request timeout: a stalled image should give up at
        // the same point a stalled API call does.
        KingfisherManager.shared.downloader.downloadTimeout = 15
    }
}
