//
//  BotMessage.swift
//
//
//  Created by Vincent Kwok on 22/11/22.
//

import DiscordKitCore
import Foundation

/// A Discord message, with convenience methods
///
/// This struct represents a message on Discord,
/// > Internally, `Message`s are converted to and from this type
/// > for easier use
public struct BotMessage {
    public var id: Snowflake { return inner.id }
    public var channelID: Snowflake { return inner.channel_id }
    public var guildID: Snowflake? { return inner.guild_id }
    public var author: User { return inner.author }
    public var member: Member? { return inner.member }
    public var timestamp: Date { return inner.timestamp }
    public var editedTimestamp: Date? { return inner.edited_timestamp }
    public var tts: Bool { return inner.tts }
    public var mentionEveryone: Bool { return inner.mention_everyone }
    public var mentions: [User] { return inner.mentions }
    public var mentionRoles: [Snowflake] { return inner.mention_roles }
    public var mentionChannels: [ChannelMention]? { return inner.mention_channels }
    public var attachments: [Attachment] { return inner.attachments }
    public var embeds: [Embed] { return inner.embeds }
    public var reactions: [Reaction]? { return inner.reactions }
    public var nonce: Nonce? { return inner.nonce }
    public var pinned: Bool { return inner.pinned }
    public var webhookId: Snowflake? { return inner.webhook_id }
    public var type: MessageType { return inner.type }
    public var activity: MessageActivity? { return inner.activity }
    public var application: Application? { return inner.application }
    public var applicationId: Snowflake? { return inner.application_id }
    public var messageReference: MessageReference? { return inner.message_reference }
    public var flags: Int? { return inner.flags }
    public var referencedMessage: BotMessage? {
        guard let ref = inner.referenced_message else { return nil }
        return Self(from: ref, rest: self.rest!)
    }
    public var interaction: MessageInteraction? { return inner.interaction }
    public var thread: Channel? { return inner.thread }
    public var components: [MessageComponent]? { return inner.components }
    public var stickerItems: [StickerItem]? { return inner.sticker_items }
    public var call: CallMessageComponent? { return inner.call }
    public var content: String { return inner.content }

    public let inner: Message

    // The REST handler associated with this message, used for message actions
    fileprivate weak var rest: DiscordREST?

    internal init(from message: Message, rest: DiscordREST) {
        self.inner = message
        self.rest = rest
    }
}

extension BotMessage {
    public func reply(_ content: String) async throws -> Message {
        return try await rest!.createChannelMsg(
            message: .init(
                content: content, message_reference: .init(message_id: id), components: []),
            id: channelID
        )
    }

    public func mentions(_ userID: Snowflake) -> Bool {
        return mentions.first(identifiedBy: userID) != nil
    }
}
