//
//  BotMessage.swift
//  
//
//  Created by Vincent Kwok on 22/11/22.
//

import Foundation
import DiscordKitCore

/// A Discord message, with convenience methods
///
/// This struct represents a message on Discord,
/// > Internally, ``Message``s are converted to and from this type
/// > for easier use
public struct BotMessage {
    public let content: String
    public let channelID: Snowflake // This will be changed very soon
    public let id: Snowflake // This too

    init(from message: Message) {
        content = message.content
        channelID = message.channel_id
        id = message.id
    }
}
