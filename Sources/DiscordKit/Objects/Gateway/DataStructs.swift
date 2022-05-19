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

/// Opcode 1 - _Heartbeat_
public struct GatewayHeartbeat: OutgoingGatewayData {}

/// Opcode 2 - _Identify_
public struct GatewayIdentify: OutgoingGatewayData {
    public let token: String
    public let properties: GatewayConnProperties
    public let compress: Bool?
    public let large_threshold: Int? // Value between 50 and 250, total number of members where the gateway will stop sending offline members in the guild member list
    public let shard: [Int]? // Array of two integers (shard_id, num_shards)
    public let presence: GatewayPresenceUpdate?
    public let capabilities: Int // Hardcode this to 253
}

/// Opcode 3 - _Presence Update_
public struct GatewayPresenceUpdate: OutgoingGatewayData {
    public let since: Int // Unix time (in milliseconds) of when the client went idle, or null if the client is not idle
    public let activities: [ActivityOutgoing]
    public let status: String
    public let afk: Bool
}

// Opcode 4 - _Voice State Update_
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

/// Opcode 6 - _Resume_
public struct GatewayResume: OutgoingGatewayData {
    public let token: String
    public let session_id: String
    public let seq: Int // Last sequence number received
}

/// Opcode 8 - _Guild Request Members_
public struct GatewayGuildRequestMembers: GatewayData {
    public let guild_id: Snowflake
    public let query: String?
    public let limit: Int
    public let presences: Bool? // Used to specify if we want the presences of the matched members
    public let user_ids: [Snowflake]? // Used to specify which users you wish to fetch
    public let nonce: String? // Nonce to identify the Guild Members Chunk response
}

/// Opcode 10 - _Hello_
public struct GatewayHello: GatewayData {
    public let heartbeat_interval: Int
}

/// Opcode 14 - _Subscribe Guild Events_
public struct SubscribeGuildEvts: OutgoingGatewayData {
    public let guild_id: Snowflake
    public let typing: Bool
    public let activities: Bool
    public let threads: Bool

	public init(guild_id: Snowflake, typing: Bool = false, activities: Bool = false, threads: Bool = false) {
		self.guild_id = guild_id
		self.typing = typing
		self.activities = activities
		self.threads = threads
	}
}
