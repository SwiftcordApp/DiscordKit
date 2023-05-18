//
//  ReadyEvt.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

/// The ready event palyoad for user accounts
public struct ReadyEvt: Decodable, GatewayData {
    // swiftlint:disable:next identifier_name
    public let v: Int
    public let user: CurrentUser
    public let users: [User]
    public let guilds: [PreloadedGuild]
    public let session_id: String
    public let user_settings: UserSettings? // Depreciated, no longer sent
    /// Protobuf of user settings
    public let user_settings_proto: String
    /// DMs for this user
    public let private_channels: [Channel]

    public let merged_members: [[Member]]

    /// The user's unreads
    ///
    /// > An implementation for unreads is still WIP in Swiftcord
    public let read_state: ReadState
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
    public let resume_gateway_url: String
}
