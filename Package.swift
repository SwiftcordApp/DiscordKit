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
		.library(name: "DiscordKit", targets: ["DiscordKit"]),
		.library(name: "DiscordKitCommon", targets: ["DiscordKitCommon"]),
	],
	dependencies: [
        .package(url: "https://github.com/ashleymills/Reachability.swift", from: "5.1.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/OpenCombine/OpenCombine.git", from: "0.13.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
	],
	targets: [
        .target(
            name: "DiscordKitCore",
            dependencies: [
                .product(name: "Reachability", package: "Reachability.swift", condition: .when(platforms: [.macOS])),
                .product(name: "OpenCombineShim", package: "OpenCombine"),
                .product(name: "Logging", package: "swift-log"),
                .target(name: "DiscordKitCommon")
            ],
            exclude: [
                "REST/README.md",
                "Gateway/README.md"
            ]
        ),
		.target(
            name: "DiscordKit",
            dependencies: [.target(name: "DiscordKitCore")]
        ),
		.target(
            name: "DiscordKitCommon",
            exclude: ["Objects/README.md"]
        ),
        .testTarget(name: "DiscordKitCoreTests", dependencies: ["DiscordKit"])
	],
    swiftLanguageVersions: [.v5]
)
