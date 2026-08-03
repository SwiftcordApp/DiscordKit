//
//  UserGuildSettings.swift
//  DiscordKit
//
//  Created by Vincent on 23/7/26.
//

import Foundation

/// Account-wide notification feature flags delivered in READY.
public struct AccountNotificationSettings: Codable, GatewayData, DefaultInitializable {
    public static let useNewNotificationsFlag = 16
    public static let mentionOnAllMessagesFlag = 32

    @DefaultZeroDecodable public var flags: Int

    public init() {
        _flags = DefaultZeroDecodable()
    }

    public init(flags: Int) {
        _flags = DefaultZeroDecodable(wrappedValue: flags)
    }

    public var usesNewNotifications: Bool {
        flags & Self.useNewNotificationsFlag != 0
    }

    public var mentionsOnAllMessages: Bool {
        flags & Self.mentionOnAllMessagesFlag != 0
    }
}

/// Per-guild notification settings delivered for user accounts.
public struct UserGuildSettings: Codable, GatewayData, DefaultInitializable {
    public struct MuteConfig: Codable, Equatable {
        @LossyOptionalDecodable public var end_time: Date?

        public init(endTime: Date? = nil) {
            _end_time = LossyOptionalDecodable(wrappedValue: endTime)
        }
    }

    public struct ChannelOverride: Codable {
        public let channel_id: Snowflake
        @DefaultFalseDecodable public var muted: Bool
        @LossyOptionalDecodable public var mute_config: MuteConfig?
        @LossyOptionalDecodable public var message_notifications: MessageNotifLevel?
        @DefaultZeroDecodable public var flags: Int

        public init(
            channelID: Snowflake,
            muted: Bool = false,
            muteConfig: MuteConfig? = nil,
            messageNotifications: MessageNotifLevel? = nil,
            flags: Int = 0
        ) {
            self.channel_id = channelID
            _muted = DefaultFalseDecodable(wrappedValue: muted)
            _mute_config = LossyOptionalDecodable(wrappedValue: muteConfig)
            _message_notifications = LossyOptionalDecodable(wrappedValue: messageNotifications)
            _flags = DefaultZeroDecodable(wrappedValue: flags)
        }
    }

    public struct Entry: Codable, GatewayData {
        public let guild_id: Snowflake?
        @DefaultFalseDecodable public var muted: Bool
        @LossyOptionalDecodable public var mute_config: MuteConfig?
        @DefaultFalseDecodable public var suppress_everyone: Bool
        @DefaultFalseDecodable public var suppress_roles: Bool
        @LossyOptionalDecodable public var message_notifications: MessageNotifLevel?
        @DefaultZeroDecodable public var flags: Int
        @LossyArrayDecodable public var channel_overrides: [ChannelOverride]
        @DefaultZeroDecodable public var version: Int

        public init(
            guildID: Snowflake?,
            muted: Bool = false,
            muteConfig: MuteConfig? = nil,
            suppressEveryone: Bool = false,
            suppressRoles: Bool = false,
            messageNotifications: MessageNotifLevel? = nil,
            flags: Int = 0,
            channelOverrides: [ChannelOverride] = [],
            version: Int = 0
        ) {
            self.guild_id = guildID
            _muted = DefaultFalseDecodable(wrappedValue: muted)
            _mute_config = LossyOptionalDecodable(wrappedValue: muteConfig)
            _suppress_everyone = DefaultFalseDecodable(wrappedValue: suppressEveryone)
            _suppress_roles = DefaultFalseDecodable(wrappedValue: suppressRoles)
            _message_notifications = LossyOptionalDecodable(wrappedValue: messageNotifications)
            _flags = DefaultZeroDecodable(wrappedValue: flags)
            _channel_overrides = LossyArrayDecodable(wrappedValue: channelOverrides)
            _version = DefaultZeroDecodable(wrappedValue: version)
        }
    }

    @LossyArrayDecodable public var entries: [Entry]
    @DefaultFalseDecodable public var partial: Bool
    @DefaultZeroDecodable public var version: Int

    public init() {
        _entries = LossyArrayDecodable()
        _partial = DefaultFalseDecodable()
        _version = DefaultZeroDecodable()
    }

    public init(
        entries: [Entry],
        partial: Bool = false,
        version: Int = 0
    ) {
        _entries = LossyArrayDecodable(wrappedValue: entries)
        _partial = DefaultFalseDecodable(wrappedValue: partial)
        _version = DefaultZeroDecodable(wrappedValue: version)
    }
}
