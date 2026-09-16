// swift-tools-version: 6.2
import PackageDescription

// Layers that run off the main actor: strict Sendable checking, no implicit isolation.
let backgroundLayer: [SwiftSetting] = [.swiftLanguageMode(.v6)]
// Layers that are main-actor by nature, matching the app target's
// SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor.
let mainActorLayer: [SwiftSetting] = [.swiftLanguageMode(.v6), .defaultIsolation(MainActor.self)]

let package = Package(
    name: "Core",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "Networking", targets: ["Networking"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"])
    ],
    targets: [
        // Feature-agnostic HTTP transport. Knows nothing about products.
        .target(name: "Networking", swiftSettings: backgroundLayer),
        // Feature-agnostic visual primitives: spacing, colours, typography.
        .target(name: "DesignSystem", swiftSettings: mainActorLayer),

        .target(name: "CoreTestSupport", dependencies: ["Networking"],
                path: "Tests/CoreTestSupport", swiftSettings: backgroundLayer),
        .testTarget(name: "NetworkingTests", dependencies: ["Networking", "CoreTestSupport"],
                    swiftSettings: backgroundLayer)
    ]
)
