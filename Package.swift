// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "DiscordKit",
	platforms: [
		.macOS(.v11)
    ],
	products: [
        .library(name: "DiscordKitCore", targets: ["DiscordKitCore"]),
		.library(name: "DiscordKit", targets: ["DiscordKit"]), // User-oriented module, simplifies use of API for UI apps
        .library(name: "DiscordKitBot", targets: ["DiscordKitBot"]) // Bot-oriented module, for use in bots
	],
	dependencies: [
        .package(url: "https://github.com/ashleymills/Reachability.swift", from: "5.1.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.6.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/OpenCombine/OpenCombine.git", from: "0.14.0"),
        .package(url: "https://github.com/tsolomko/SWCompression.git", from: "4.8.0"),
        .package(url: "https://github.com/tesseract-one/WebSocket.swift.git", from: "0.2.0")
	],
	targets: [
        .target(
            name: "DiscordKitCore",
            dependencies: [
                .product(name: "Reachability", package: "Reachability.swift", condition: .when(platforms: [.macOS])),
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "OpenCombine", package: "OpenCombine", condition: .when(platforms: [.linux])),
                .product(name: "OpenCombineFoundation", package: "OpenCombine", condition: .when(platforms: [.linux])),
                .product(name: "SWCompression", package: "SWCompression", condition: .when(platforms: [.linux])),
                .product(name: "WebSocket", package: "WebSocket.swift", condition: .when(platforms: [.linux]))
            ],
            exclude: [
                "REST/README.md",
                "Gateway/README.md",
                "Objects/README.md"
            ]
        ),
		.target(
            name: "DiscordKit",
            dependencies: [
                .target(name: "DiscordKitCore"),
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        .target(
            name: "DiscordKitBot",
            dependencies: [
                .target(name: "DiscordKitCore"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf")
            ]
        ),
        .testTarget(name: "DiscordKitCommonTests", dependencies: ["DiscordKitCore"])
	],
    swiftLanguageVersions: [.v5]
)
