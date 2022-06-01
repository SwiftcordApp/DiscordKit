//
//  DataStructs.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 20/2/22.
//

import Foundation

public protocol GatewayData: Decodable {}
public protocol OutgoingGatewayData: Encodable {}

/// Connection properties used to construct client info that is sent
/// in the ``GatewayIdentify`` payload
public struct GatewayConnProperties: OutgoingGatewayData {
    /// OS the client is running on
    ///
    /// Always `Mac OS X`
    public let os: String
    
    /// Browser name
    ///
    /// Observed values were `Chrome` when running on Google Chrome and
    /// `Discord Client` when running in the desktop client.
    ///
    /// > For now, this value is hardcoded to `Discord Client` in the
    /// > ``DiscordAPI/getSuperProperties()`` method. Customisability
    /// > might be added in a future release.
    public let browser: String
    
    /// Release channel of target official client
    ///
    /// Refer to ``GatewayConfig/clientParity`` for more details.
    public let release_channel: String?
    
    /// Version of target official client
    ///
    /// Refer to ``GatewayConfig/clientParity`` for more details.
    public let client_version: String?
    
    /// OS version
    ///
    /// The version of the OS the client is running on. This is dynamically
    /// retrieved in ``DiscordAPI/getSuperProperties()`` by calling `uname()`.
    /// For macOS, it is the version of the Darwin Kernel, which is `21.4.0`
    /// as of macOS `12.3`.
    public let os_version: String?
    
    /// Machine arch
    ///
    /// The arch of the machine the client is running on. This is dynamically
    /// retrieved in ``DiscordAPI/getSuperProperties()`` by calling `uname()`.
    /// For macOS, it could be either `x86_64` (Intel) or `arm64` (Apple Silicon).
    public let os_arch: String?
    
    /// System locale
    ///
    /// The locale (language) of the system. This is hardcoded to be `en-US` for now.
    public let system_locale: String?
    
    /// Build number of target official client
    ///
    /// Refer to ``GatewayConfig/clientParity`` for more details.
    public let client_build_number: Int?
}

/// Gateway Heartbeat
///
/// Sent when establishing a new session with the Gateway, to identify the client.
/// Refer to ``GatewayHello/heartbeat_interval`` for more details regarding
/// the heartbeat timings.
///
/// > Outgoing Gateway data struct for opcode 2
public struct GatewayHeartbeat: OutgoingGatewayData {
    private let seq: Int?
    
    init(_ seq: Int?) { self.seq = seq }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(seq)
    }
}

/// Gateway Identify
///
/// Sent every ``GatewayHello/heartbeat_interval``, to prevent the Gateway
/// from closing the connection and
///
/// > Outgoing Gateway data struct for opcode 1
public struct GatewayIdentify: OutgoingGatewayData {
    public let token: String
    public let properties: GatewayConnProperties
    public let compress: Bool?
    public let large_threshold: Int? // Value between 50 and 250, total number of members where the gateway will stop sending offline members in the guild member list
    public let shard: [Int]? // Array of two integers (shard_id, num_shards)
    public let presence: GatewayPresenceUpdate?
    public let capabilities: Int // Hardcode this to 253
}

/// Presence Update
///
/// Sent to update the presence of the current client.
///
/// > Outgoing Gateway data struct for opcode 3
public struct GatewayPresenceUpdate: OutgoingGatewayData {
    public let since: Int // Unix time (in milliseconds) of when the client went idle, or null if the client is not idle
    public let activities: [ActivityOutgoing]
    public let status: String
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

/// Gateway Resume
///
/// Sent when attempting to resume a broken websocket connection.
///
/// > Outgoing Gateway data struct for opcode 6
public struct GatewayResume: OutgoingGatewayData {
    public let token: String
    public let session_id: String
    public let seq: Int // Last sequence number received
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
