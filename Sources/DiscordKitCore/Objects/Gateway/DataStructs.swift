//
//  DataStructs.swift
//  
//
//  Created by Vincent Kwok on 7/6/22.
//
//  Structs here are internal to this package
//  and not meant for external use

import Foundation

public protocol GatewayData: Decodable {}
public protocol OutgoingGatewayData: Encodable {}

/// Presence Update
///
/// Sent to update the presence of the current client.
///
/// > Outgoing Gateway data struct for opcode 3
public struct GatewayPresenceUpdate: OutgoingGatewayData {
    public init(since: Int, activities: [ActivityOutgoing], status: PresenceStatus, afk: Bool) {
        self.since = since
        self.activities = activities
        self.status = status
        self.afk = afk
    }

    public let since: Int // Unix time (in milliseconds) of when the client went idle, or null if the client is not idle
    public let activities: [ActivityOutgoing]
    public let status: PresenceStatus
    public let afk: Bool
}

/// Voice State Update
///
/// Sent to update the client's voice, deaf and video state.
///
/// > Outgoing Gateway data struct for opcode 4
public struct GatewayVoiceStateUpdate: OutgoingGatewayData, GatewayData {
    public let guild_id: Snowflake?
    public let channel_id: Snowflake? // ID of the voice channel client wants to join (null if disconnecting)
    public let self_mute: Bool
    public let self_deaf: Bool
    public let self_video: Bool?

    public init(guild_id: Snowflake?, channel_id: Snowflake?, self_mute: Bool, self_deaf: Bool, self_video: Bool?) {
        self.guild_id = guild_id
        self.channel_id = channel_id
        self.self_mute = self_mute
        self.self_deaf = self_deaf
        self.self_video = self_video
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // Encoding containers directly so nil optionals get encoded as "null" and not just removed
        try container.encode(self_mute, forKey: .self_mute)
        try container.encode(self_deaf, forKey: .self_deaf)
        try container.encode(self_video, forKey: .self_video)
        try container.encode(channel_id, forKey: .channel_id)
        try container.encode(guild_id, forKey: .guild_id)
    }
}

/// Guild Request Members
///
/// > Outgoing Gateway data struct for opcode 8
public struct GatewayGuildRequestMembers: GatewayData {
    public let guild_id: Snowflake
    public let query: String?
    public let limit: Int
    public let presences: Bool? // Used to specify if we want the presences of the matched members
    public let user_ids: [Snowflake]? // Used to specify which users you wish to fetch
    public let nonce: String? // Nonce to identify the Guild Members Chunk response
}

/// Gateway Hello
///
/// > Incoming Gateway data struct for opcode 10
public struct GatewayHello: GatewayData {
    /// Interval between outgoing heartbeats, in ms
    ///
    /// The Gateway has an approx 25% time tolerance to delayed heartbeats,
    /// that is, it will close the connection if no heartbeat is received after
    /// ``heartbeat_interval``\*125% ms from the last received heartbeat.
    /// As per official docs, the first heartbeat should be sent
    /// ``heartbeat_interval``\*[0...1] ms after receiving the ``GatewayHello``
    /// payload, where [0...1] is a random double from 0-1.
    public let heartbeat_interval: Int
}

/// Subscribe Guild Events
///
/// > Outgoing Gateway data struct for opcode 11
public struct SubscribeGuildEvts: OutgoingGatewayData {
    public let guild_id: Snowflake
    public let typing: Bool?
    public let activities: Bool?
    public let threads: Bool?
    public let members: [Snowflake]?

    public init(guild_id: Snowflake, typing: Bool? = nil, activities: Bool? = nil, threads: Bool? = nil, members: [Snowflake]? = nil) {
        self.guild_id = guild_id
        self.typing = typing
        self.activities = activities
        self.threads = threads
        self.members = members
    }
}

/// Current client state, sent with the ``GatewayIdentify`` payload
///
/// > Warning: This should only be sent in identify payloads for user accounts. Bot accounts don't need this!
struct ClientState: OutgoingGatewayData {
    struct GuildVersion: OutgoingGatewayData { }

    let api_code_version: Int
    let guild_versions: GuildVersion
    let highest_last_message_id: Snowflake
    let initial_guild_id: Snowflake?
    let private_channels_version: String
    let read_state_version: Int
    let user_guild_settings_version: Int
    let user_settings_version: Int
}
/// Placeholder struct for `guild_hashes` in `client_state`
///
/// This is currently empty, and simply serves as a placeholder.
struct GuildHashes: OutgoingGatewayData {

}

/// Gateway Heartbeat
///
/// Sent when establishing a new session with the Gateway, to identify the client.
/// Refer to ``GatewayHello/heartbeat_interval`` for more details regarding
/// the heartbeat timings.
///
/// > Outgoing Gateway data struct for opcode 2
struct GatewayHeartbeat: OutgoingGatewayData {
    let seq: Int?

    init(_ seq: Int?) { self.seq = seq }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(seq)
    }
}

/// Gateway Identify
///
/// Sent every ``GatewayHello/heartbeat_interval``, to prevent the Gateway
/// from closing the connection
///
/// > Outgoing Gateway data struct for opcode 1
struct GatewayIdentify: OutgoingGatewayData {
    let token: String
    let properties: GatewayConnProperties
    let compress: Bool?
    let large_threshold: Int? // Value between 50 and 250, total number of members where the gateway will stop sending offline members in the guild member list
    let shard: [Int]? // Array of two integers (shard_id, num_shards)
    let presence: GatewayPresenceUpdate?
    let client_state: ClientState?
    let capabilities: Int? // Must be set for user accounts
    let intents: Intents?
}

/// Gateway Resume
///
/// Sent when attempting to resume a broken websocket connection.
///
/// > Outgoing Gateway data struct for opcode 6
public struct GatewayResume: OutgoingGatewayData {
    public let token: String
    public let session_id: String
    @NullEncodable public var seq: Int? // Last sequence number received
}
