//
//  ReadyEvt.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

public enum DefaultResumeGatewayURL: DefaultDecodingType {
    public static var defaultValue: URL {
        URL(string: DiscordKitConfig.default.gateway)!
    }
}

public typealias DefaultResumeGatewayURLDecodable = DefaultDecodable<DefaultResumeGatewayURL>

/// The ready event palyoad for user accounts
public struct ReadyEvt: Decodable, GatewayData {
    // swiftlint:disable:next identifier_name
    public let v: Int
    public let user: CurrentUser
    public let users: [User]
    public let guilds: [DecodeThrowable<PreloadedGuild>]
    public let session_id: String
    public let user_settings: UserSettings? // Depreciated, no longer sent
    /// Protobuf of user settings
    @DefaultEmptyStringDecodable public var user_settings_proto: String
    /// DMs for this user
    @DefaultEmptyArrayDecodable public var private_channels: [DecodeThrowable<Channel>]

    @LossyNestedArrayDecodable public var merged_members: [[Member]]

    /// The user's unreads
    ///
    /// > An implementation for unreads is still WIP in Swiftcord
    public let read_state: ReadState

    /// Per-guild and per-channel notification settings, including mutes.
    @DefaultInitialDecodable public var user_guild_settings: UserGuildSettings

    /// Account-wide notification behavior flags.
    @DefaultInitialDecodable public var notification_settings: AccountNotificationSettings

    public let auth_token: String?

    @DefaultResumeGatewayURLDecodable public var resume_gateway_url: URL
}

/// The ready event payload for bot accounts
public struct BotReadyEvt: Decodable, GatewayData {
    // swiftlint:disable:next identifier_name
    public let v: Int
    public let user: User
    public let guilds: [GuildUnavailable]
    public let session_id: String
    public let shard: [Int]? // Included for inclusivity, will not be used
    public let application: PartialApplication
    public let resume_gateway_url: URL
}
