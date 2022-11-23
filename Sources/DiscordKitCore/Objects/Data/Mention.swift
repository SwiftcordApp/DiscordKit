//
//  Mention.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

public enum AllowedMentionTypes: String, Codable {
    case role = "roles" // Controls role mentions
    case user = "users" // Controls user mentions
    case everyone = "everyone" // Controls @everyone and @here mentions
}

public struct AllowedMentions: Codable {
    public init(parse: [AllowedMentionTypes]? = nil, roles: [Snowflake]? = nil, users: [Snowflake]? = nil, replied_user: Bool? = nil) {
        self.parse = parse
        self.roles = roles
        self.users = users
        self.replied_user = replied_user
    }

    /// An array of allowed mention types to parse from the content.
    public let parse: [AllowedMentionTypes]?
    /// Array of role\_ids to mention (Max size of 100)
    public let roles: [Snowflake]?
    /// Array of user\_ids to mention (Max size of 100)
    public let users: [Snowflake]?
    /// For replies, whether to mention the author of the message being replied to (default false)
    public let replied_user: Bool?
}

public struct ChannelMention: Codable {
    public let id: Snowflake
    public let guild_id: Snowflake
    public let type: ChannelType
    public let name: String
}
