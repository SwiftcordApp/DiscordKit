//
//  VoiceEvt.swift
//  DiscordAPI
//

import Foundation

/// Voice server update event.
///
/// Sent after a voice state update when Discord has selected the voice server
/// endpoint and token to use for the voice websocket handoff.
public struct VoiceServerUpdate: GatewayData {
    public let token: String
    public let guild_id: Snowflake?
    public let endpoint: String?
    public let channel_id: Snowflake?

    public init(token: String, guild_id: Snowflake?, endpoint: String?, channel_id: Snowflake? = nil) {
        self.token = token
        self.guild_id = guild_id
        self.endpoint = endpoint
        self.channel_id = channel_id
    }
}

/// Batch voice state update event.
public struct VoiceStateUpdateBatch: GatewayData {
    public let guild_id: Snowflake?
    public let voice_states: [VoiceState]

    private enum CodingKeys: String, CodingKey {
        case guild_id
        case voice_states
    }

    public init(guild_id: Snowflake? = nil, voice_states: [VoiceState]) {
        self.guild_id = guild_id
        self.voice_states = voice_states
    }

    public init(from decoder: Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        if let voiceStates = try? singleValueContainer.decode([VoiceState].self) {
            guild_id = nil
            voice_states = voiceStates
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        guild_id = try container.decodeIfPresent(Snowflake.self, forKey: .guild_id)
        voice_states = try container.decode([VoiceState].self, forKey: .voice_states)
    }
}

/// Call create event.
///
/// User accounts receive this for DM/group calls. The embedded voice states are
/// useful for establishing the initial participant set.
public struct CallCreate: GatewayData {
    public let channel_id: Snowflake
    public let message_id: Snowflake?
    public let region: String?
    public let ringing: [Snowflake]?
    public let unavailable: Bool?
    public let voice_states: [VoiceState]?

    public init(
        channel_id: Snowflake,
        message_id: Snowflake? = nil,
        region: String? = nil,
        ringing: [Snowflake]? = nil,
        unavailable: Bool? = nil,
        voice_states: [VoiceState]? = nil
    ) {
        self.channel_id = channel_id
        self.message_id = message_id
        self.region = region
        self.ringing = ringing
        self.unavailable = unavailable
        self.voice_states = voice_states
    }
}
