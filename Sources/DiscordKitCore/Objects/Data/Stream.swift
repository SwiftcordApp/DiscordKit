//
//  Stream.swift
//
//  Created by Zerui on 12/8/26.
//

import Foundation

/// The channel scope encoded into a Discord Go Live stream key.
public enum DiscordStreamType: String, Codable, Sendable {
    case guild
    case call
}

/// A validated Discord Go Live stream key.
///
/// Guild streams use `guild:<guild id>:<channel id>:<owner id>` and private
/// call streams use `call:<channel id>:<owner id>`.
public struct DiscordStreamKey: RawRepresentable, Codable, Hashable, Sendable,
    CustomStringConvertible {
    public let streamType: DiscordStreamType
    public let guildID: Snowflake?
    public let channelID: Snowflake
    public let ownerID: Snowflake

    public init(guildID: Snowflake, channelID: Snowflake, ownerID: Snowflake) {
        self.streamType = .guild
        self.guildID = guildID
        self.channelID = channelID
        self.ownerID = ownerID
    }

    public init(callChannelID: Snowflake, ownerID: Snowflake) {
        self.streamType = .call
        self.guildID = nil
        self.channelID = callChannelID
        self.ownerID = ownerID
    }

    public init?(rawValue: String) {
        let components = rawValue.split(separator: ":", omittingEmptySubsequences: false)
        guard let typeComponent = components.first,
              let streamType = DiscordStreamType(rawValue: String(typeComponent)) else {
            return nil
        }

        switch streamType {
        case .guild:
            guard components.count == 4,
                  components[1].isEmpty == false,
                  components[2].isEmpty == false,
                  components[3].isEmpty == false else {
                return nil
            }
            self.init(
                guildID: String(components[1]),
                channelID: String(components[2]),
                ownerID: String(components[3])
            )
        case .call:
            guard components.count == 3,
                  components[1].isEmpty == false,
                  components[2].isEmpty == false else {
                return nil
            }
            self.init(callChannelID: String(components[1]), ownerID: String(components[2]))
        }
    }

    public var rawValue: String {
        switch streamType {
        case .guild:
            return [streamType.rawValue, guildID ?? "", channelID, ownerID].joined(separator: ":")
        case .call:
            return [streamType.rawValue, channelID, ownerID].joined(separator: ":")
        }
    }

    public var description: String { rawValue }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        guard let value = Self(rawValue: rawValue) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid Discord stream key: \(rawValue)"
            )
        }
        self = value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

/// Acknowledges creation of a Go Live stream and provides its RTC identity.
public struct StreamCreate: Codable, GatewayData, Sendable {
    public let stream_key: DiscordStreamKey
    public let region: String?
    public let viewer_ids: [Snowflake]?
    public let rtc_server_id: Snowflake?
    public let rtc_channel_id: Snowflake?
    public let paused: Bool?
}

/// Supplies the RTC endpoint and token for a Go Live stream connection.
public struct StreamServerUpdate: Codable, GatewayData, Sendable {
    public let stream_key: DiscordStreamKey
    public let endpoint: String?
    public let token: String
}

/// Updates mutable server-side state for a Go Live stream.
public struct StreamUpdate: Codable, GatewayData, Sendable {
    public let stream_key: DiscordStreamKey
    public let region: String?
    public let viewer_ids: [Snowflake]?
    public let paused: Bool?
}

/// Signals that a Go Live stream RTC session has ended or become unavailable.
public struct StreamDelete: Codable, GatewayData, Sendable {
    public let stream_key: DiscordStreamKey
    public let unavailable: Bool?
    public let reason: String?
}

/// The lightweight CDN image Discord exposes before a viewer joins a stream.
public struct StreamPreview: Codable, Equatable, Sendable {
    public let url: String?

    public init(url: String?) {
        self.url = url
    }

    public var previewURL: URL? {
        url.flatMap(URL.init(string:))
    }
}
