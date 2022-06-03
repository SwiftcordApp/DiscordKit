//
//  CachedState.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 22/2/22.
//

import Foundation

/// A struct for storing cached data from the Gateway
///
/// Used in ``DiscordGateway/cache``.
public class CachedState: ObservableObject, Equatable {
    public static func == (lhs: CachedState, rhs: CachedState) -> Bool {
        lhs.guilds == rhs.guilds &&
        lhs.dms == rhs.dms &&
        lhs.user == rhs.user &&
        lhs.userSettings == rhs.userSettings
    }

    /// Dictionary of guilds the user is in
    ///
    /// > The guild's ID is its key
    public private(set) var guilds: [Snowflake: Guild] = [:]

    /// DM channels the user is in
	public var dms: [Channel] = []

    /// Cached object of current user
	public var user: CurrentUser?

    /// Cached users, initially populated from `READY` event and might
    /// grow over time
    public var users: [Snowflake: User] = [:]

    /// User settings
    ///
    /// View ``UserSettings`` for information about each entry.
    public var userSettings: UserSettings?

    // MARK: Guilds

    func remove(_ guild: GuildUnavailable) {
        guilds.removeValue(forKey: guild.id)
    }

    func update(_ guild: Guild) {
        guilds.updateValue(guild, forKey: guild.id)
    }

    // MARK: Channels

    func append(_ channel: Channel) {
        guard let identifier = channel.guild_id else {
            return
        }

        guilds[identifier]?.channels?.append(channel)
    }

    func remove(_ channel: Channel) {
        guard let identifier = channel.guild_id else {
            return
        }

        guilds[identifier]?.channels?.removeAll(matchingIdentifierFor: channel)
    }

    func update(_ channel: Channel) {
        guard
            let guildID = channel.guild_id,
            let channelIndex = guilds[guildID]?
                .channels?
                .firstIndex(matchingIdentifierFor: channel)
        else {
            return
        }

        guilds[channel.guild_id!]?.channels?[channelIndex] = channel
    }

    // MARK: Messages

    func append(_ message: Message) {
        if let guild = message.guild_id,
           let idx = guilds[guild]?
           .channels?
           .firstIndex(where: { $0.id == message.channel_id }) {
            guilds[guild]?.channels?[idx].last_message_id = message.id
        } else if let idx = dms.firstIndex(where: { $0.id == message.channel_id }) {
            dms[idx].last_message_id = message.id
        }
    }
}
