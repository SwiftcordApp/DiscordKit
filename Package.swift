// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "DiscordKit",
	platforms: [
		.macOS(.v12)
	],
	products: [
		.library(name: "DiscordKit", targets: ["DiscordKit"]),
		.library(name: "DiscordKitCommon", targets: ["DiscordKitCommon"])
	],
	dependencies: [
		.package(url: "https://github.com/ashleymills/Reachability.swift", from: "5.1.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
	],
	targets: [
		.target(
			name: "DiscordKit",
			dependencies: [
				.product(name: "Reachability", package: "Reachability.swift"),
                .target(name: "DiscordKitCommon")
			],
			exclude: [
				"REST/README.md",
				"Gateway/README.md",
				"Objects/README.md"
			]
		),
		.target(name: "DiscordKitCommon"),
        .testTarget(name: "DiscordKitTests", dependencies: ["DiscordKit"])
	]
)
