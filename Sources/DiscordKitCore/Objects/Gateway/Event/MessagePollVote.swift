//
//  MessagePollVote.swift
//  DiscordKit
//
//  Created by Vincent on 30/8/26.
//

import Foundation

/// A vote added to or removed from one answer of a message poll.
public struct MessagePollVote: Codable, GatewayData {
    public init(
        user_id: Snowflake,
        channel_id: Snowflake,
        message_id: Snowflake,
        guild_id: Snowflake? = nil,
        answer_id: Int
    ) {
        self.user_id = user_id
        self.channel_id = channel_id
        self.message_id = message_id
        self.guild_id = guild_id
        self.answer_id = answer_id
    }

    public let user_id: Snowflake
    public let channel_id: Snowflake
    public let message_id: Snowflake
    public let guild_id: Snowflake?
    public let answer_id: Int
}
