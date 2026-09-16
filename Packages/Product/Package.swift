// swift-tools-version: 6.2
import PackageDescription

let backgroundLayer: [SwiftSetting] = [.swiftLanguageMode(.v6)]
let mainActorLayer: [SwiftSetting] = [.swiftLanguageMode(.v6), .defaultIsolation(MainActor.self)]

let package = Package(
    name: "Product",
    platforms: [.iOS(.v18), .macOS(.v14)],
    products: [
        .library(name: "ProductDomain", targets: ["ProductDomain"]),
        .library(name: "ProductData", targets: ["ProductData"]),
        .library(name: "ProductPresentation", targets: ["ProductPresentation"]),
        .library(name: "ProductUI", targets: ["ProductUI"])
    ],
    dependencies: [
        .package(path: "../Core")
    ],
    targets: [
        // Entities and the protocols the feature needs. Depends on nothing --
        // not Core, not Foundation-heavy transport, not SwiftUI.
        .target(name: "ProductDomain", swiftSettings: backgroundLayer),

        // Wire format lives here and nowhere else: DTOs, mappers, and the
        // concrete loaders that satisfy ProductDomain's protocols.
        .target(name: "ProductData",
                dependencies: ["ProductDomain", .product(name: "Networking", package: "Core")],
                swiftSettings: backgroundLayer),

        // ViewModels and view state. Talks to protocols, never to ProductData.
        .target(name: "ProductPresentation", dependencies: ["ProductDomain"],
                swiftSettings: mainActorLayer),

        // SwiftUI views. Cannot see ProductData or Networking -- so it cannot
        // build its own dependencies, which is the point.
        .target(name: "ProductUI",
                dependencies: ["ProductPresentation", .product(name: "DesignSystem", package: "Core")],
                swiftSettings: mainActorLayer),

        .target(name: "ProductTestSupport", dependencies: ["ProductDomain"],
                path: "Tests/ProductTestSupport", swiftSettings: backgroundLayer),
        .testTarget(name: "ProductDomainTests", dependencies: ["ProductDomain", "ProductTestSupport"],
                    swiftSettings: backgroundLayer),
        .testTarget(name: "ProductDataTests", dependencies: ["ProductData", "ProductTestSupport"],
                    swiftSettings: backgroundLayer),
        .testTarget(name: "ProductPresentationTests",
                    dependencies: ["ProductPresentation", "ProductTestSupport"],
                    swiftSettings: mainActorLayer)
    ]
)
