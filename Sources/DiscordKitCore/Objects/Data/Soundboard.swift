//
//  Soundboard.swift
//  DiscordKitCore
//
//  Created by Vincent on 7/9/26.
//

import Foundation

public struct SoundboardSound: Codable, Identifiable, Equatable, Sendable {
    public var id: Snowflake { sound_id }
    public let sound_id: Snowflake
    public let name: String
    public let volume: Double
    public var guild_id: Snowflake?
    public let emoji_id: Snowflake?
    public let emoji_name: String?
    public let available: Bool?
    public let user_id: Snowflake?

    public var isAvailable: Bool { available ?? true }
    public var url: URL { URL(string: "https://cdn.discordapp.com/soundboard-sounds/\(sound_id)")! }
}

public struct GuildSoundboardSounds: GatewayData {
    public let guild_id: Snowflake
    public let soundboard_sounds: [SoundboardSound]
}

public struct SoundboardSoundDelete: GatewayData {
    public let guild_id: Snowflake
    public let sound_id: Snowflake
}

public struct VoiceChannelEffect: GatewayData {
    public let channel_id: Snowflake
    public let user_id: Snowflake
    public let sound_id: Snowflake?
    public let sound_volume: Double?
}

public struct RequestSoundboardSounds: OutgoingGatewayData {
    public let guild_ids: [Snowflake]

    public init(guild_ids: [Snowflake]) {
        self.guild_ids = guild_ids
    }
}
