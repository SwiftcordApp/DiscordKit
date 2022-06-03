//
//  UserSettings.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 10/5/22.
//

import Foundation

public enum UITheme: String, Codable {
    case dark = "dark"
    case light = "light"
}

func mergeUserSettings(_ old: UserSettings?, new: UserSettings) -> UserSettings {
    return UserSettings(
        guild_positions: new.guild_positions ?? old?.guild_positions,
        guild_folders: new.guild_folders ?? old?.guild_folders,
        inline_attachment_media: new.inline_attachment_media ?? old?.inline_attachment_media,
        locale: new.locale ?? old?.locale,
        theme: new.theme ?? old?.theme,
        timezone_offset: new.timezone_offset ?? old?.timezone_offset,
        developer_mode: new.developer_mode ?? old?.developer_mode,
        message_display_compact: new.message_display_compact ?? old?.message_display_compact
    )
}

public struct UserSettings: Decodable, GatewayData, Equatable {
    /// Sequence of guild IDs
    ///
    /// The IDs of ordered guilds are in this array. If the guild
    /// is not ordered (i.e. never dragged from its initial position at
    /// the top of the server list), its id will not be in this array.
    public let guild_positions: [Snowflake]?

    /// Guild folders
    public let guild_folders: [GuildFolder]?

    /// If the new inline attachment upload experience is enabled
    public let inline_attachment_media: Bool?

    /// User interface locale
    public let locale: Locale?

    /// Client UI theme
    ///
    /// Although there's a sync with system setting in the official client,
    /// only light/dark themes are saved in the user settings. 
    public let theme: UITheme?

    /// User timezone, in minutes
    public let timezone_offset: Int?

    /// If developer mode is enabled (mainly enables copying of IDs)
    public let developer_mode: Bool?

    /// If compact message view is enabled
    public let message_display_compact: Bool?
}
