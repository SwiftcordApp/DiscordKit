//
//  Config.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 20/2/22.
//
//  Base config for many parts in Discord API

import Foundation

// Target official Discord client version for feature parity
public enum ClientReleaseChannel: String {
    case canary = "canary"
    case beta = "beta"
    case stable = "stable"
}

/// Information about the target official client to emulate
///
/// These values can be found by inspecting requests from the official
/// desktop client in its DevTools.
public struct ClientParityVersion {
    public let version: String
    public let buildNumber: Int
    public let releaseCh: ClientReleaseChannel
    public let electronVersion: String
}

/// Configuration used throughout this package
///
/// Contains various info related to gateway connection, URLs,
/// and the official client version that is emulated.
///
/// > Warning: Do not modify these values unless you know what you're
/// > doing. You risk sending invalid data to the endpoints and getting
/// > your account flagged and banned if values are set incorrectly.
public struct GatewayConfig {
    /// Base Discord URL
	public let baseURL: String
    /// CDN URL for retrieving attachments, avatars etc.
	public let cdnURL: String
    /// Discord API endpoint version; Only version 9 is implemented &
    /// supported
	public let version: Int
    /// Client version that this implementation aims to emulate
    ///
    /// Currently the only missing piece of emulating the official
    /// desktop client completely is ETK packing/unpacking.
	public let parity: ClientParityVersion
    
    /// Base REST endpoint URL
	public let restBase: String
    /// Gateway WebSocket URL
	public let gateway: String
    
    /// Populate struct values with provided parameters
	public init(
        baseURL: String,
        version: Int,
        clientParity: ClientParityVersion
    ) {
        self.cdnURL = "https://cdn.discordapp.com/"
        self.baseURL = "https://\(baseURL)/"
        self.version = version
        parity = clientParity
        gateway = "wss://gateway.discord.gg/?v=\(version)&encoding=json&compress=zlib-stream"
        restBase = "\(self.baseURL)api/v\(version)/"
    }

	public static let clientParity = ClientParityVersion(
        version: "0.0.283",
        buildNumber: 115689,
        releaseCh: .canary,
		electronVersion: "13.6.6"
    )
	public static let `default` = GatewayConfig(
        baseURL: "canary.discord.com",
        version: 9,
        clientParity: Self.clientParity
    )
}
