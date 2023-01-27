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
        case footer
    }

    // Always rich as that's the only type supported
    private let type = EmbedType.rich

    // Fields are implicitly internal(get) as we do not want them appearing in autocomplete
    fileprivate(set) var title: String?
    fileprivate(set) var description: String?
    fileprivate(set) var url: URL?
    fileprivate(set) var timestamp: Date?
    fileprivate(set) var color: Int?
    fileprivate(set) var footer: EmbedFooter?
    private let fields: [Field]?

    public init(fields: [Field]? = nil) {
        self.fields = fields
    }
    public init(@EmbedFieldBuilder fields: () -> [Field]) {
        self.init(fields: fields())
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

    func footer(_ text: String) -> Self {
        var embed = self
        embed.footer = .init(text: text)
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
