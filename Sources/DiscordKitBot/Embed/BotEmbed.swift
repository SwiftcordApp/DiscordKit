//
//  BotEmbed.swift
//  
//
//  Created by Vincent Kwok on 16/12/22.
//

import Foundation
import DiscordKitCore

public struct BotEmbed: Codable {
    /// An embed field
    public struct Field: Codable {
        /// Create an embed field
        public init(_ name: String, value: String, inline: Bool = false) {
            assert(!name.isEmpty, "Name cannot be empty")
            assert(!value.isEmpty, "Value cannot be empty")

            self.name = name
            self.value = value
            self.inline = inline
        }
        /// Construct an empty field
        ///
        /// This populates both the name and inline field values with `\u{200b}`, as
        /// [recommended in the Discord.JS Guide](https://discordjs.guide/popular-topics/embeds.html#using-the-embed-constructor)
        public init(inline: Bool = false) {
            self.init("\u{200b}", value: "\u{200b}", inline: inline)
        }

        public let name: String
        public let value: String
        public let inline: Bool
    }

    enum CodingKeys: CodingKey {
        case type
        case title
        case description
        case url
        case timestamp
        case color
        case fields
    }

    // Fields are implicitly internal(get) as we do not want them appearing in autocomplete
    fileprivate(set) var title: String?
    fileprivate(set) var description: String?
    fileprivate(set) var url: URL?
    fileprivate(set) var timestamp: Date?
    fileprivate(set) var color: Int?
    private let fields: [Field]?

    public init(fields: [Field]? = nil) {
        self.fields = fields
    }
    public init(@EmbedFieldBuilder fields: () -> [Field]) {
        self.init(fields: fields())
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        title = try container.decodeIfPresent(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        url = try container.decodeIfPresent(URL.self, forKey: .url)
        timestamp = try container.decodeIfPresent(Date.self, forKey: .timestamp)
        color = try container.decodeIfPresent(Int.self, forKey: .color)
        fields = try container.decodeIfPresent([BotEmbed.Field].self, forKey: .fields)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // Always encode rich type because that's the only type of embed supported
        try container.encode(EmbedType.rich, forKey: .type)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(url, forKey: .url)
        try container.encodeIfPresent(timestamp, forKey: .timestamp)
        try container.encodeIfPresent(color, forKey: .color)
        try container.encodeIfPresent(fields, forKey: .fields)
    }
}

public extension BotEmbed {
    func title(_ title: String?) -> Self {
        var embed = self
        embed.title = title
        return embed
    }

    func description(_ description: String?) -> Self {
        var embed = self
        embed.description = description
        return embed
    }

    func url(_ url: URL?) -> Self {
        var embed = self
        embed.url = url
        return embed
    }
    func url(_ newURL: String?) -> Self {
        url(newURL != nil ? URL(string: newURL!) : nil)
    }

    func timestamp(_ timestamp: Date?) -> Self {
        var embed = self
        embed.timestamp = timestamp
        return embed
    }

    func color(_ color: Int?) -> Self {
        var embed = self
        embed.color = color
        return embed
    }
}
