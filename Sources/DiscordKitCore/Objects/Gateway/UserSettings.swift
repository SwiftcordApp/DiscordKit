//
//  UserSettings.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 10/5/22.
//

import Foundation

public enum UITheme: String, Codable {
    case dark
    case light
}

public struct UserSettings: Decodable, GatewayData, Equatable {
    /// Sequence of guild IDs
    ///
    /// The IDs of ordered guilds are in this array. If the guild
    /// is not ordered (i.e. never dragged from its initial position at
    /// the top of the server list), its id will not be in this array.
    public let guild_positions: [Snowflake]?

    /// Guild folders
    public let guild_folders: [GuildFolderItem]?

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

extension UserSettings {
    public func merged(with settings: UserSettings) -> UserSettings {
        return UserSettings(
            guild_positions: settings.guild_positions ?? guild_positions,
            guild_folders: settings.guild_folders ?? guild_folders,
            inline_attachment_media: settings.inline_attachment_media ?? inline_attachment_media,
            locale: settings.locale ?? locale,
            theme: settings.theme ?? theme,
            timezone_offset: settings.timezone_offset ?? timezone_offset,
            developer_mode: settings.developer_mode ?? developer_mode,
            message_display_compact: settings.message_display_compact ?? message_display_compact
        )
    }
}
