//
//  UserGuildSettings.swift
//  DiscordKit
//
//  Created by Vincent on 23/7/26.
//

import Foundation

/// Per-guild notification settings delivered for user accounts.
public struct UserGuildSettings: Codable, GatewayData, DefaultInitializable {
    public struct MuteConfig: Codable, Equatable {
        public let end_time: Date?

        public init(endTime: Date? = nil) {
            self.end_time = endTime
        }
    }

    public struct ChannelOverride: Codable {
        public let channel_id: Snowflake
        @DefaultFalseDecodable public var muted: Bool
        public let mute_config: MuteConfig?

        public init(
            channelID: Snowflake,
            muted: Bool = false,
            muteConfig: MuteConfig? = nil
        ) {
            self.channel_id = channelID
            _muted = DefaultFalseDecodable(wrappedValue: muted)
            self.mute_config = muteConfig
        }
    }

    public struct Entry: Codable, GatewayData {
        public let guild_id: Snowflake?
        @DefaultFalseDecodable public var muted: Bool
        public let mute_config: MuteConfig?
        @DefaultEmptyArrayDecodable public var channel_overrides: [ChannelOverride]
        @DefaultZeroDecodable public var version: Int

        public init(
            guildID: Snowflake?,
            muted: Bool = false,
            muteConfig: MuteConfig? = nil,
            channelOverrides: [ChannelOverride] = [],
            version: Int = 0
        ) {
            self.guild_id = guildID
            _muted = DefaultFalseDecodable(wrappedValue: muted)
            self.mute_config = muteConfig
            _channel_overrides = DefaultEmptyArrayDecodable(wrappedValue: channelOverrides)
            _version = DefaultZeroDecodable(wrappedValue: version)
        }
    }

    @DefaultEmptyArrayDecodable public var entries: [Entry]
    @DefaultFalseDecodable public var partial: Bool
    @DefaultZeroDecodable public var version: Int

    public init() {
        _entries = DefaultEmptyArrayDecodable()
        _partial = DefaultFalseDecodable()
        _version = DefaultZeroDecodable()
    }

    public init(
        entries: [Entry],
        partial: Bool = false,
        version: Int = 0
    ) {
        _entries = DefaultEmptyArrayDecodable(wrappedValue: entries)
        _partial = DefaultFalseDecodable(wrappedValue: partial)
        _version = DefaultZeroDecodable(wrappedValue: version)
    }
}
