//
//  GuildMembersChunk.swift
//
//
//  Created by Vincent Kwok on 11/12/23.
//

import Foundation

/// Guild Members Chunk
/// 
/// Sent in response to a
public struct GuildMembersChunk: GatewayData {
    public let guild_id: Snowflake
    public let members: [Member]
    public let chunk_index: Int
    public let chunk_count: Int
    public let not_found: [Snowflake]?
    public let presences: [Presence]?
    public let nonce: String?
}
