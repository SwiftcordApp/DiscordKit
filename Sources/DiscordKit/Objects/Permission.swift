//
//  Permission.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 20/2/22.
//

import Foundation

public struct Permissions: OptionSet, Codable {
    public let rawValue: UInt64

    /// Allows creation of instant invites
    public static let createInstantInvite = Permissions(rawValue: 1 << 0)
    /// Allows kicking members
    public static let kickMembers = Permissions(rawValue: 1 << 1)
    /// Allows banning members
    public static let banMembers = Permissions(rawValue: 1 << 2)
    /// Allows all permissions and bypasses channel permission overwrites
    public static let administrator = Permissions(rawValue: 1 << 3)
    /// Allows management and editing of channels
    public static let manageChannels = Permissions(rawValue: 1 << 4)
    /// Allows management and editing of the guild
    public static let manageGuild = Permissions(rawValue: 1 << 5)
    /// Allows for the addition of reactions to messages
    public static let addReactions = Permissions(rawValue: 1 << 6)
    /// Allows for viewing of audit logs
    public static let viewAuditLog = Permissions(rawValue: 1 << 7)
    /// Allows for using priority speaker in a voice channel
    public static let prioritySpeaker = Permissions(rawValue: 1 << 8)
    /// Allows the user to go live
    public static let stream = Permissions(rawValue: 1 << 9)
    /// Allows guild members to view a channel, which includes reading messages in text channels and joining voice channels
    public static let viewChannel = Permissions(rawValue: 1 << 10)
    /// Allows for sending messages in a channel and creating threads in a forum (does not allow sending messages in threads)
    public static let sendMessages = Permissions(rawValue: 1 << 11)
    /// Allows for sending of /tts messages
    public static let sendTtsMessages = Permissions(rawValue: 1 << 12)
    /// Allows for deletion of other users messages
    public static let manageMessages = Permissions(rawValue: 1 << 13)
    /// Links sent by users with this permission will be auto-embedded
    public static let embedLinks = Permissions(rawValue: 1 << 14)
    /// Allows for uploading images and files
    public static let attachFiles = Permissions(rawValue: 1 << 15)
    /// Allows for reading of message history
    public static let readMessageHistory = Permissions(rawValue: 1 << 16)
    /// Allows for using the @everyone tag to notify all users in a channel, and the @here tag to notify all online users in a channel
    public static let mentionEveryone = Permissions(rawValue: 1 << 17)
    /// Allows the usage of custom emojis from other servers
    public static let useExternalEmojis = Permissions(rawValue: 1 << 18)
    /// Allows for viewing guild insights
    public static let viewGuildInsights = Permissions(rawValue: 1 << 19)
    /// Allows for joining of a voice channel
    public static let connect = Permissions(rawValue: 1 << 20)
    /// Allows for speaking in a voice channel
    public static let speak = Permissions(rawValue: 1 << 21)
    /// Allows for muting members in a voice channel
    public static let muteMembers = Permissions(rawValue: 1 << 22)
    /// Allows for deafening of members in a voice channel
    public static let deafenMembers = Permissions(rawValue: 1 << 23)
    /// Allows for moving of members between voice channels
    public static let moveMembers = Permissions(rawValue: 1 << 24)
    /// Allows for using voice-activity-detection in a voice channel
    public static let useVad = Permissions(rawValue: 1 << 25)
    /// Allows for modification of own nickname
    public static let changeNickname = Permissions(rawValue: 1 << 26)
    /// Allows for modification of other users nicknames
    public static let manageNicknames = Permissions(rawValue: 1 << 27)
    /// Allows management and editing of roles
    public static let manageRoles = Permissions(rawValue: 1 << 28)
    /// Allows management and editing of webhooks
    public static let manageWebhooks = Permissions(rawValue: 1 << 29)
    /// Allows management and editing of emojis and stickers
    public static let manageEmojisAndStickers = Permissions(rawValue: 1 << 30)
    /// Allows members to use application commands, including slash commands and context menu commands.
    public static let useApplicationCommands = Permissions(rawValue: 1 << 31)
    /// Allows for requesting to speak in stage channels. (This permission is under active development and may be changed or removed.)
    public static let requestToSpeak = Permissions(rawValue: 1 << 32)
    /// Allows for creating, editing, and deleting scheduled events
    public static let manageEvents = Permissions(rawValue: 1 << 33)
    /// Allows for deleting and archiving threads, and viewing all private threads
    public static let manageThreads = Permissions(rawValue: 1 << 34)
    /// Allows for creating public and announcement threads
    public static let createPublicThreads = Permissions(rawValue: 1 << 35)
    /// Allows for creating private threads
    public static let createPrivateThreads = Permissions(rawValue: 1 << 36)
    /// Allows the usage of custom stickers from other servers
    public static let useExternalStickers = Permissions(rawValue: 1 << 37)
    /// Allows for sending messages in threads
    public static let sendMessagesInThreads = Permissions(rawValue: 1 << 38)
    /// Allows for using Activities (applications with the EMBEDDED flag) in a voice channel
    public static let useEmbeddedActivities = Permissions(rawValue: 1 << 39)
    /// Allows for timing out users to prevent them from sending or reacting to messages in chat and threads, and from speaking in voice and stage channels
    public static let moderateMembers = Permissions(rawValue: 1 << 40)

    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self.init(rawValue: UInt64(raw) ?? 0)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(String(rawValue))
    }
}

public enum PermOverwriteType: Int, Codable {
    case role = 0
    case member = 1
}

public struct PermOverwrite: Codable {
    public let id: Snowflake
    public let type: PermOverwriteType
    public let allow: Permissions
    public let deny: Permissions
}

/*
 From discord docs:
 Roles represent a set of permissions attached to a group of users.
 Roles have names, colors, and can be "pinned" to the side bar,
 causing their members to be listed separately. Roles can have
 separate permission profiles for the global context (guild) and
 channel context. The @everyone role has the same ID as the guild it belongs to.
 */

public struct Role: Codable {
    public let id: Snowflake
    public let name: String
    public let color: Int
    public let hoist: Bool // If this role is pinned in the user listing
    public let icon: String? // Role icon hash
    public let unicode_emoji: String?
    public let position: Int
    public let permissions: Permissions // Permission bit set
    public let managed: Bool // Whether this role is managed by an integration
    public let mentionable: Bool
    public let tags: RoleTags?
}

public struct RoleTags: Codable {
    public let bot_id: Snowflake?
    public let integration_id: Snowflake?
    public let premium_subscriber: Bool?
}
