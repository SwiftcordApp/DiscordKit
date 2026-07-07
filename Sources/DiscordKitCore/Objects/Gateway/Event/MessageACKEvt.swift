//
//  MessageACKEvent.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 11/5/22.
//

import Foundation

public struct MessageACKEvt: Codable, GatewayData {
    public let message_id: Snowflake
    public let channel_id: Snowflake
    public let version: Int
    /// Set when the user explicitly marked the channel unread ("mark as unread") on another client.
    public let manual: Bool?
    /// Mention count to restore for a manual ack.
    public let mention_count: Int?
}
