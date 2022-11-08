//
//  CachedState.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 22/2/22.
//

import Foundation
import DiscordKitCore
import DiscordKitCommon

/// A struct for storing cached data from the Gateway
///
/// Used in ``DiscordGateway/cache``.
public class CachedState: ObservableObject {
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
    public private(set) var users: [Snowflake: User] = [:]

    /// User settings
    ///
    /// View ``UserSettings`` for information about each entry.
    public var userSettings: UserSettings?

    /// Populates the cache using the provided event.
    /// - Parameter event: An incoming Gateway "ready" event.
    func configure(using event: ReadyEvt) {
        event.guilds.forEach(appendOrReplace(_:))
        dms = event.private_channels
        user = event.user
        event.users.forEach(appendOrReplace(_:))
        userSettings = event.user_settings
    }

    // MARK: Guilds

    /// Updates or appends the provided guild.
    /// - Parameter guild: The guild you want to update or append to the cache.
    func appendOrReplace(_ guild: Guild) {
        guilds.updateValue(guild, forKey: guild.id)
    }

    /// Removes any guilds with an identifier matching the identifier of the provided guild parameter.
    /// - Parameter guild: A ``Guild`` instance whose identifier will be used to remove any guilds with a matching identifier.
    func remove(_ guild: GuildUnavailable) {
        guilds.removeValue(forKey: guild.id)
    }

    // MARK: Channels

    /// Appends the provided channel to the appropriate cached guild.
    /// - Parameter channel: The channel to append.
    func append(_ channel: Channel) {
        guard let identifier = channel.guild_id else {
            return
        }

        guilds[identifier]?.channels?.append(channel)
    }

    /// Removes the provided channel from the appropriate cached guild.
    /// - Parameter channel: The channel to remove.
    func remove(_ channel: Channel) {
        guard let identifier = channel.guild_id else {
            return
        }

        guilds[identifier]?.channels?.removeAll(matchingIdentifierFor: channel)
    }

    /// Replaces the first channel with an identifier that matches the provided channel's identifier..
    /// - Parameter channel: The channel to replace
    func replace(_ channel: Channel) {
        guard
            let guildID = channel.guild_id,
            let channelIndex = guilds[guildID]?
                .channels?
                .firstIndex(matchingIdentifierFor: channel)
        else {
            return
        }

        guilds[guildID]?.channels?[channelIndex] = channel
    }

    // MARK: Messages

    /// Appends or replaces  the given message within the appropriate channel.
    /// - Parameter message: The message to append.
    func appendOrReplace(_ message: Message) {
        if let idx = dms.firstIndex(where: { $0.id == message.channel_id }) {
            dms[idx].last_message_id = message.id
        }
    }

    // MARK: Users

    /// Appends or replaces the provided user in the cache.
    /// - Parameter user: The user to cache.
    func appendOrReplace(_ user: User) {
        users.updateValue(user, forKey: user.id)
    }

    // MARK: User Settings

    /// If the cache does not contain user settings, the provided settings will be set directly. If the cache already contains user settings, the provided settings will be merged with the existing settings.
    /// - Parameter updatedSettings: The user settings to cache.
    func mergeOrReplace(_ updatedSettings: UserSettings) {
        if let existingSettings = userSettings {
            userSettings = existingSettings.merged(with: updatedSettings)
        } else {
            userSettings = updatedSettings
        }
    }
}
