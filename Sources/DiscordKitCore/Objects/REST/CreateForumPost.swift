//
//  CreateForumPost.swift
//  DiscordKit
//
//  Created by Vincent on 18/8/26.
//

import Foundation

public struct CreateForumPostRequest: Encodable, Sendable {
    public let name: String
    public let auto_archive_duration: Int
    public let applied_tags: [Snowflake]
    public let message: CreateForumPostMessage

    public init(
        name: String,
        autoArchiveDuration: Int,
        appliedTags: [Snowflake],
        message: CreateForumPostMessage
    ) {
        self.name = name
        self.auto_archive_duration = autoArchiveDuration
        self.applied_tags = appliedTags
        self.message = message
    }
}

public struct CreateForumPostMessage: Encodable, Sendable {
    public let content: String?
    public let sticker_ids: [Snowflake]
    public let attachments: [NewAttachment]?
    public let flags: Int?

    public init(
        content: String?,
        stickerIDs: [Snowflake] = [],
        attachments: [NewAttachment] = [],
        flags: Int? = nil
    ) {
        self.content = content
        self.sticker_ids = stickerIDs
        self.attachments = attachments.isEmpty ? nil : attachments
        self.flags = flags
    }
}
