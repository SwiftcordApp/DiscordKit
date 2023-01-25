//
//  InteractionResponse.swift
//  
//
//  Created by Vincent Kwok on 17/12/22.
//

import Foundation
import DiscordKitCore

// MARK: - Interaction Response
public struct InteractionResponse: Encodable {
    public init(type: InteractionResponse.ResponseType, data: InteractionResponse.ResponseData?) {
        self.type = type
        self.data = data
    }

    public enum ResponseType: Int, Codable {
        case pong = 1
        case interactionReply = 4
        case deferredInteractionReply = 5
        case deferredUpdateMessage = 6
        case updateMessage = 7
        case appCommandAutocompleteResult = 8
        case modal = 9
    }

    public enum ResponseData: Encodable {
        public struct Message: Codable {
            public init(
                content: String? = nil, tts: String? = nil, embeds: [BotEmbed]? = nil,
                allowed_mentions: AllowedMentions? = nil,
                flags: DiscordKitCore.Message.Flags? = nil,
                components: [MessageComponent]? = nil,
                attachments: [NewAttachment]? = nil
            ) {
                self.content = content
                self.tts = tts
                self.embeds = embeds
                self.allowed_mentions = allowed_mentions
                self.flags = flags
                self.components = components
                self.attachments = attachments
            }

            public let content: String?
            public let tts: String?
            public let embeds: [BotEmbed]?
            public let allowed_mentions: AllowedMentions?
            public let flags: DiscordKitCore.Message.Flags?
            public let components: [MessageComponent]?
            public let attachments: [NewAttachment]?
        }

        case message(Message)
        // case autocompleteResult
        // case modal

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()

            switch self {
            case .message(let message): try container.encode(message)
            }
        }
    }

    public let type: ResponseType
    public let data: ResponseData?
}
