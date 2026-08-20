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
    @ReadyGuildsDecodable public var guilds: [DecodeThrowable<PreloadedGuild>]
    public var unavailableGuilds: [GuildUnavailable] { _guilds.unavailableGuilds }
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

@propertyWrapper
public struct ReadyGuildsDecodable: Decodable {
    public let wrappedValue: [DecodeThrowable<PreloadedGuild>]
    public let unavailableGuilds: [GuildUnavailable]

    public init(from decoder: Decoder) throws {
        var entries = try decoder.unkeyedContainer()
        var guilds = [DecodeThrowable<PreloadedGuild>]()
        var unavailableGuilds = [GuildUnavailable]()
        guilds.reserveCapacity(entries.count ?? 0)

        while !entries.isAtEnd {
            let entryDecoder = try entries.superDecoder()
            let guild = try DecodeThrowable<PreloadedGuild>(from: entryDecoder)
            guilds.append(guild)

            if case .failure = guild.result,
               let unavailableGuild = try? GuildUnavailable(from: entryDecoder),
               unavailableGuild.unavailable == true {
                unavailableGuilds.append(unavailableGuild)
            }
        }

        self.wrappedValue = guilds
        self.unavailableGuilds = unavailableGuilds
    }
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
