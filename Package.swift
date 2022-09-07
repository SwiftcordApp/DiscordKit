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
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.6.0"),
	],
	targets: [
        .target(
            name: "DiscordKitCore",
            dependencies: [
                .product(name: "Reachability", package: "Reachability.swift", condition: .when(platforms: [.macOS])),
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
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
        .testTarget(name: "DiscordKitCommonTests", dependencies: ["DiscordKitCommon"])
	],
    swiftLanguageVersions: [.v5]
)
