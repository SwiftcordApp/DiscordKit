//
//  WebhookResponse.swift
//  
//
//  Created by Vincent Kwok on 17/12/22.
//

import Foundation
import DiscordKitCore

public struct WebhookResponse: Encodable {
    public init(
        content: String? = nil, embeds: [BotEmbed]? = nil, tts: Bool? = nil,
        attachments: [NewAttachment]? = nil,
        components: [Component]? = nil,
        username: String? = nil, avatarURL: URL? = nil,
        allowedMentions: AllowedMentions? = nil,
        flags: Message.Flags? = nil,
        threadName: String? = nil
    ) {
        assert(content != nil || embeds != nil, "Must have at least one of content or embeds (files unsupported)")

        self.content = content
        self.username = username
        self.avatar_url = avatarURL
        self.tts = tts
        self.embeds = embeds
        self.allowed_mentions = allowedMentions
        self.components = components
        self.attachments = attachments
        self.flags = flags
        self.thread_name = threadName
    }

    public let content: String?
    public let username: String?
    public let avatar_url: URL?
    public let tts: Bool?
    public let embeds: [BotEmbed]?
    public let allowed_mentions: AllowedMentions?
    public let components: [Component]?
    public let attachments: [NewAttachment]?
    public let flags: Message.Flags?
    public let thread_name: String?

    enum CodingKeys: CodingKey {
        case content
        case username
        case avatar_url
        case tts
        case embeds
        case allowed_mentions
        case components
        case attachments
        case flags
        case thread_name
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(content, forKey: .content)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(avatar_url, forKey: .avatar_url)
        try container.encodeIfPresent(tts, forKey: .tts)
        try container.encodeIfPresent(embeds, forKey: .embeds)
        try container.encodeIfPresent(allowed_mentions, forKey: .allowed_mentions)
        try container.encodeIfPresent(attachments, forKey: .attachments)
        try container.encodeIfPresent(flags, forKey: .flags)
        try container.encodeIfPresent(thread_name, forKey: .thread_name)

        if let components {
            var componentContainer = container.nestedUnkeyedContainer(forKey: .components)
            for component in components {
                try componentContainer.encode(component)
            }
        }
    }
}
