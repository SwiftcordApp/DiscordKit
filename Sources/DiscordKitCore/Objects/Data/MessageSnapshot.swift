//
//  MessageSnapshot.swift
//  DiscordKit
//
//  Created by Vincent on 31/7/26.
//

import Foundation

/// How a message reference relates the destination message to its source.
public enum MessageReferenceType: Int, Codable {
    case defaultReference = 0
    case forward = 1
    case unknown = -1

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = Self(rawValue: try container.decode(Int.self)) ?? .unknown
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

/// A point-in-time copy associated with a forwarded message.
public struct MessageSnapshot: Codable {
    public init(message: SnapshotMessage) {
        self.message = message
    }

    public let message: SnapshotMessage

    var renderingSignature: RenderingSignature {
        RenderingSignature(message)
    }
}

extension MessageSnapshot {
    struct RenderingSignature: Hashable {
        struct Mention: Hashable {
            let id: Snowflake
            let username: String
            let globalName: String?
        }

        let content: String
        let attachments: [Attachment]
        let embeds: [Embed]
        let flags: Int
        let mentions: [Mention]

        init(_ message: SnapshotMessage) {
            content = message.content
            attachments = message.attachments
            embeds = message.embeds
            flags = message.flags
            mentions = message.mentions.map {
                Mention(id: $0.id, username: $0.username, globalName: $0.global_name)
            }
        }
    }
}

/// The authorless subset of message fields included in a forward snapshot.
public struct SnapshotMessage: Codable {
    public init(
        type: MessageType = .defaultMsg,
        content: String = "",
        timestamp: Date,
        edited_timestamp: Date? = nil,
        attachments: [Attachment] = [],
        embeds: [Embed] = [],
        flags: Int = 0,
        mentions: [User] = [],
        mention_roles: [Snowflake] = [],
        stickers: [Sticker] = [],
        sticker_items: [StickerItem] = [],
        components: [MessageComponent] = []
    ) {
        _decodedType = LossyOptionalDecodable(wrappedValue: type)
        _content = DefaultEmptyStringDecodable(wrappedValue: content)
        self.timestamp = timestamp
        self.edited_timestamp = edited_timestamp
        _attachments = LossyArrayDecodable(wrappedValue: attachments)
        _embeds = LossyArrayDecodable(wrappedValue: embeds)
        _flags = DefaultZeroDecodable(wrappedValue: flags)
        _mentions = LossyArrayDecodable(wrappedValue: mentions)
        _mention_roles = LossyArrayDecodable(wrappedValue: mention_roles)
        _stickers = LossyArrayDecodable(wrappedValue: stickers)
        _sticker_items = LossyArrayDecodable(wrappedValue: sticker_items)
        _components = LossyArrayDecodable(wrappedValue: components)
    }

    @LossyOptionalDecodable private var decodedType: MessageType?
    @DefaultEmptyStringDecodable public var content: String
    public let timestamp: Date
    public let edited_timestamp: Date?
    @LossyArrayDecodable public var attachments: [Attachment]
    @LossyArrayDecodable public var embeds: [Embed]
    @DefaultZeroDecodable public var flags: Int
    @LossyArrayDecodable public var mentions: [User]
    @LossyArrayDecodable public var mention_roles: [Snowflake]
    @LossyArrayDecodable public var stickers: [Sticker]
    @LossyArrayDecodable public var sticker_items: [StickerItem]
    @LossyArrayDecodable public var components: [MessageComponent]

    public var type: MessageType {
        decodedType ?? .defaultMsg
    }

    /// Whether Discord has removed the source captured by this snapshot.
    public var sourceMessageDeleted: Bool {
        flags & Int(Message.Flags.sourceMessageDeleted.rawValue) != 0
    }

    private enum CodingKeys: String, CodingKey {
        case decodedType = "type"
        case content
        case timestamp
        case edited_timestamp
        case attachments
        case embeds
        case flags
        case mentions
        case mention_roles
        case stickers
        case sticker_items
        case components
    }
}
