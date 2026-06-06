//
//  DiscordKitConfig.swift
//  
//
//  Created by Vincent Kwok on 7/6/22.
//

import Foundation

// Target official Discord client version for feature parity
enum ClientReleaseChannel: String {
    case canary
    case beta
    case stable
}

/// Information about the target official client to emulate
///
/// These values can be found by inspecting requests from the official web
/// client in browser DevTools.
public struct ClientParityVersion {
    let buildNumber: Int
    let releaseCh: ClientReleaseChannel
    let browserVersion: String
    let browserUserAgent: String
    let osVersion: String
}

/// Configuration used throughout DiscordKit
///
/// Contains various info related to gateway connection, URLs,
/// and the official client version that is emulated.
///
/// > Warning: Do not modify these values unless you know what you're
/// > doing. You risk sending invalid data to the endpoints and getting
/// > your account flagged and banned if values are set incorrectly.
public struct DiscordKitConfig {
    /// Base Discord URL
    public let baseURL: URL
    /// CDN URL for retrieving attachments, avatars etc.
    public let cdnURL: String
    /// Discord API endpoint version; Only version 9 is implemented &
    /// supported
    public let version: Int

    /// Properties of the client
    public let properties: GatewayConnProperties

    /// The user agent to be sent with requests to the Discord API
    public let userAgent: String

    /// If zlib stream compression is enabled for communication with the gateway
    public let streamCompression: Bool

    /// Base REST endpoint URL
    public let restBase: URL
    /// Gateway WebSocket URL
    public var gateway: String {
        "wss://gateway.discord.gg/?v=\(version)&encoding=json\(streamCompression ? "&compress=zlib-stream" : "")"
    }

    // The token to use to authenticate with both the Discord REST and Gateway APIs
    // public let token: String

    /// The ``Intents`` to provide when identifying with the Gateway
    ///
    /// This is used for event filtering, reducing WebSocket traffic by choosing "buckets" of
    /// events to receive.
    ///
    /// > Important: Some intents are "privileged" and must be enabled in the Developer Portal.
    public let intents: Intents?

    /// If the current configuration is for a bot account
    public var isBot: Bool { intents != nil }

    // MARK: Configuration constants
    public static let libraryName = "DiscordKit"
    public static let discordKitBuild = 1

    /// Populate struct values with provided parameters
    public init(
        baseURL: String = "canary.discord.com",
        version: Int? = nil,
        properties: GatewayConnProperties? = nil,
        intents: Intents? = nil,
        streamCompression: Bool = true
    ) {
        self.cdnURL = "https://cdn.discordapp.com/"
        self.baseURL = URL(string: "https://\(baseURL)/")!
        self.intents = intents
        self.streamCompression = streamCompression

        if let version {
            self.version = version
        } else {
            self.version = intents == nil ? 9 : 10
        }
        if intents == nil {
            userAgent = Self.clientParity.browserUserAgent
        } else {
            userAgent = "DiscordBot (https://github.com/SwiftcordApp/DiscordKit, \(Self.discordKitBuild))"
        }
        if let properties = properties {
            self.properties = properties
        } else {
            self.properties = Self.getSuperProperties(
                releaseCh: Self.clientParity.releaseCh,
                buildNumber: Self.clientParity.buildNumber,
                browserVersion: Self.clientParity.browserVersion,
                browserUserAgent: Self.clientParity.browserUserAgent,
                osVersion: Self.clientParity.osVersion
            )
        }
        restBase = self.baseURL.appendingPathComponent("api").appendingPathComponent("v\(self.version)")
    }

    /// Populate a ``GatewayConnProperties`` struct with some constant
    /// values + some dynamic versions
    ///
    /// - Returns: Populated ``GatewayConnProperties``
    internal static func getSuperProperties(
        releaseCh: ClientReleaseChannel,
        buildNumber: Int,
        browserVersion: String,
        browserUserAgent: String,
        osVersion: String
    ) -> GatewayConnProperties {
        GatewayConnProperties(
            browser: "Chrome",
            release_channel: releaseCh.rawValue,
            os_version: osVersion,
            system_locale: Locale.englishUS.rawValue,
            client_build_number: buildNumber,
            browser_user_agent: browserUserAgent,
            browser_version: browserVersion
        )
    }

    /// Client version that this implementation aims to emulate
    ///
    /// Values captured from the official web client.
    public static let clientParity = ClientParityVersion(
        buildNumber: 556_969,
        releaseCh: .stable,
        browserVersion: "149.0.0.0",
        browserUserAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36",
        osVersion: "10.15.7"
    )
    public static var `default` = Self()
}
