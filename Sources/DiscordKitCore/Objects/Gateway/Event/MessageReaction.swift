//
//  MessageReaction.swift
//  DiscordAPI
//
//  Created by Vincent on 8/7/26.
//

import Foundation

public struct MessageReactionAdd: Decodable, GatewayData {
    public init(
        user_id: Snowflake,
        channel_id: Snowflake,
        message_id: Snowflake,
        guild_id: Snowflake? = nil,
        member: Member? = nil,
        emoji: Emoji,
        message_author_id: Snowflake? = nil,
        burst: Bool = false,
        burst_colors: [String]? = nil,
        type: Int? = nil
    ) {
        self.user_id = user_id
        self.channel_id = channel_id
        self.message_id = message_id
        self.guild_id = guild_id
        self.member = member
        self.emoji = emoji
        self.message_author_id = message_author_id
        _burst = DefaultFalseDecodable(wrappedValue: burst)
        self.burst_colors = burst_colors
        self.type = type
    }

    public let user_id: Snowflake
    public let channel_id: Snowflake
    public let message_id: Snowflake
    public let guild_id: Snowflake?
    public let member: Member?
    public let emoji: Emoji
    public let message_author_id: Snowflake?
    @DefaultFalseDecodable public var burst: Bool
    public let burst_colors: [String]?
    public let type: Int?
}

public struct MessageReactionRemove: Decodable, GatewayData {
    public init(
        user_id: Snowflake,
        channel_id: Snowflake,
        message_id: Snowflake,
        guild_id: Snowflake? = nil,
        emoji: Emoji,
        burst: Bool = false,
        type: Int? = nil
    ) {
        self.user_id = user_id
        self.channel_id = channel_id
        self.message_id = message_id
        self.guild_id = guild_id
        self.emoji = emoji
        _burst = DefaultFalseDecodable(wrappedValue: burst)
        self.type = type
    }

    public let user_id: Snowflake
    public let channel_id: Snowflake
    public let message_id: Snowflake
    public let guild_id: Snowflake?
    public let emoji: Emoji
    @DefaultFalseDecodable public var burst: Bool
    public let type: Int?
}

public struct MessageReactionRemoveAll: Codable, GatewayData {
    public init(channel_id: Snowflake, message_id: Snowflake, guild_id: Snowflake? = nil) {
        self.channel_id = channel_id
        self.message_id = message_id
        self.guild_id = guild_id
    }

    public let channel_id: Snowflake
    public let message_id: Snowflake
    public let guild_id: Snowflake?
}

public struct MessageReactionRemoveEmoji: Codable, GatewayData {
    public init(
        channel_id: Snowflake,
        message_id: Snowflake,
        guild_id: Snowflake? = nil,
        emoji: Emoji
    ) {
        self.channel_id = channel_id
        self.message_id = message_id
        self.guild_id = guild_id
        self.emoji = emoji
    }

    public let channel_id: Snowflake
    public let message_id: Snowflake
    public let guild_id: Snowflake?
    public let emoji: Emoji
}
