// swift-tools-version: 6.2
import PackageDescription

// Layers that run off the main actor: strict Sendable checking, no implicit isolation.
let backgroundLayer: [SwiftSetting] = [.swiftLanguageMode(.v6)]
// Layers that are main-actor by nature, matching the app target's
// SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor.
let mainActorLayer: [SwiftSetting] = [.swiftLanguageMode(.v6), .defaultIsolation(MainActor.self)]

let package = Package(
    name: "Core",
    // iOS is the only shipping platform. macOS is declared so `swift build` works on the
    // host, which is what Scripts/check-layering.sh relies on to verify the layer graph.
    platforms: [.iOS(.v18), .macOS(.v14)],
    products: [
        .library(name: "Networking", targets: ["Networking"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"])
    ],
    dependencies: [
        // Image loading, caching and SwiftUI integration. Contained inside DesignSystem
        // so no other module — and not the app target — imports it directly.
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "8.12.0"))
    ],
    targets: [
        // Feature-agnostic HTTP transport. Knows nothing about products.
        .target(name: "Networking", swiftSettings: backgroundLayer),
        // Feature-agnostic visual primitives: spacing, colours, typography, states.
        .target(name: "DesignSystem", dependencies: ["Kingfisher"], swiftSettings: mainActorLayer),

        .target(name: "CoreTestSupport", dependencies: ["Networking"],
                path: "Tests/CoreTestSupport", swiftSettings: backgroundLayer),
        .testTarget(name: "NetworkingTests", dependencies: ["Networking", "CoreTestSupport"],
                    swiftSettings: backgroundLayer)
    ]
)
