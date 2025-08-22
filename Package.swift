// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "NodeGraph",
    platforms: [
        .iOS(.v15), .macOS(.v12), .tvOS(.v15), .visionOS(.v1)
    ],
    products: [
        .library(name: "NodeGraph", targets: ["NodeGraph"])
    ],
    targets: [
        .target(
            name: "NodeGraph",
            dependencies: [],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release)),
                .define("SWIFT_PACKAGE")
            ]),
        .testTarget(name: "NodeGraphTests", dependencies: ["NodeGraph"]),
    ]
)
