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
/// These values can be found by inspecting requests from the official
/// desktop client in its DevTools.
public struct ClientParityVersion {
    let version: String
    let buildNumber: Int
    let releaseCh: ClientReleaseChannel
    let electronVersion: String
}

/// Connection properties used to construct client info that is sent
/// in the ``GatewayIdentify`` payload
public struct GatewayConnProperties: OutgoingGatewayData {
    /// OS the client is running on
    ///
    /// Always `Mac OS X`
    let os: String

    /// Browser name
    ///
    /// Observed values were `Chrome` when running on Google Chrome and
    /// `Discord Client` when running in the desktop client.
    ///
    /// > For now, this value is hardcoded to `Discord Client` in the
    /// > ``DiscordAPI/getSuperProperties()`` method. Customisability
    /// > might be added in a future release.
    let browser: String

    /// Release channel of target official client
    ///
    /// Refer to ``GatewayConfig/clientParity`` for more details.
    let release_channel: String?

    /// Version of target official client
    ///
    /// Refer to ``GatewayConfig/clientParity`` for more details.
    let client_version: String?

    /// OS version
    ///
    /// The version of the OS the client is running on. This is dynamically
    /// retrieved in ``DiscordAPI/getSuperProperties()`` by calling `uname()`.
    /// For macOS, it is the version of the Darwin Kernel, which is `21.4.0`
    /// as of macOS `12.3`.
    let os_version: String?

    /// Machine arch
    ///
    /// The arch of the machine the client is running on. This is dynamically
    /// retrieved in ``DiscordAPI/getSuperProperties()`` by calling `uname()`.
    /// For macOS, it could be either `x86_64` (Intel) or `arm64` (Apple Silicon).
    let os_arch: String?

    /// System locale
    ///
    /// The locale (language) of the system. This is hardcoded to be `en-US` for now.
    let system_locale: String?

    /// Build number of target official client
    ///
    /// Refer to ``GatewayConfig/clientParity`` for more details.
    let client_build_number: Int?
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
    public let baseURL: String
    /// CDN URL for retrieving attachments, avatars etc.
    public let cdnURL: String
    /// Discord API endpoint version; Only version 9 is implemented &
    /// supported
    public let version: Int

    /// Properties of the client
    public let properties: GatewayConnProperties

    /// The user agent to be sent with requests to the Discord API
    public let userAgent: String

    /// Base REST endpoint URL
    public let restBase: String
    /// Gateway WebSocket URL
    public let gateway: String

    /// The token to use to authenticate with both the Discord REST and Gateway APIs
    //public let token: String

    // MARK: Configuration constants
    /// DiscordKit subsystem constant
    public static let subsystem = "com.cryptoalgo.DiscordKit"
    public static let discordKitBuild = 1

    /// Populate struct values with provided parameters
    public init(
        baseURL: String = "canary.discord.com",
        version: Int = 9,
        properties: GatewayConnProperties? = nil,
        userAgent: String? = nil
    ) {
        self.cdnURL = "https://cdn.discordapp.com/"
        self.baseURL = "https://\(baseURL)/"
        self.version = version
        if let userAgent = userAgent {
            self.userAgent = userAgent
        } else {
            self.userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) discord/\(version) Chrome/91.0.4472.164 Electron/\(Self.clientParity.electronVersion) Safari/537.36"
        }
        if let properties = properties {
            self.properties = properties
        } else {
            self.properties = Self.getSuperProperties(
                releaseCh: Self.clientParity.releaseCh,
                clientVersion: Self.clientParity.version,
                buildNumber: Self.clientParity.buildNumber
            )
        }
        gateway = "wss://gateway.discord.gg/?v=\(version)&encoding=json&compress=zlib-stream"
        restBase = "\(self.baseURL)api/v\(version)/"
    }

    /// Populate a ``GatewayConnProperties`` struct with some constant
    /// values + some dynamic versions
    ///
    /// - Returns: Populated ``GatewayConnProperties``
    internal static func getSuperProperties(
        releaseCh: ClientReleaseChannel,
        clientVersion: String,
        buildNumber: Int
    ) -> GatewayConnProperties {
        var systemInfo = utsname()
        uname(&systemInfo)

        // Ugly method to turn C char array into String
        func parseUname<T>(ptr: UnsafePointer<T>) -> String {
            ptr.withMemoryRebound(
                to: UInt8.self,
                capacity: MemoryLayout.size(ofValue: ptr)
            ) { return String(cString: $0) }
        }

        let release = withUnsafePointer(to: systemInfo.release) {
            parseUname(ptr: $0)
        }
        // This should be called arch instead
        let machine = withUnsafePointer(to: systemInfo.machine) { parseUname(ptr: $0) }

        return GatewayConnProperties(
            os: "Mac OS X",
            browser: "Discord Client",
            release_channel: releaseCh.rawValue,
            client_version: clientVersion,
            os_version: release,
            os_arch: machine,
            system_locale: Locale.englishUS.rawValue,
            client_build_number: buildNumber
        )
    }

    /// Client version that this implementation aims to emulate
    ///
    /// Currently the only missing piece of emulating the official
    /// desktop client completely is ETF packing/unpacking.
    public static let clientParity = ClientParityVersion(
        version: "0.0.283",
        buildNumber: 115689,
        releaseCh: .canary,
        electronVersion: "13.6.6"
    )
    public static var `default` = Self()
}
