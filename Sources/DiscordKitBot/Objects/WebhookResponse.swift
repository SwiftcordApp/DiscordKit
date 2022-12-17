//
//  WebhookResponse.swift
//  
//
//  Created by Vincent Kwok on 17/12/22.
//

import Foundation
import DiscordKitCore

public struct WebhookResponse: Codable {
    public init(
        content: String? = nil, embeds: [BotEmbed]? = nil, tts: Bool? = nil,
        attachments: [NewAttachment]? = nil,
        components: [MessageComponent]? = nil,
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
    public let components: [MessageComponent]?
    public let attachments: [NewAttachment]?
    public let flags: Message.Flags?
    public let thread_name: String?
}
