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
/// > Internally, `Message`s are converted to and from this type
/// > for easier use
public struct BotMessage {
    public let content: String
    public let channelID: Snowflake // This will be changed very soon
    public let id: Snowflake // This too

    // The REST handler associated with this message, used for message actions
    fileprivate weak var rest: DiscordREST?

    internal init(from message: Message, rest: DiscordREST) {
        content = message.content
        channelID = message.channel_id
        id = message.id

        self.rest = rest
    }
}

public extension BotMessage {
    func reply(_ content: String) async throws -> Message {
        return try await rest!.createChannelMsg(
            message: .init(content: content, message_reference: .init(message_id: id), components: []),
            id: channelID
        )
    }
}
