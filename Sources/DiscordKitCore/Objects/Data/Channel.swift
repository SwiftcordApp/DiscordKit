//
//  Channel.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

public enum VideoQualityMode: Int, Codable {
    case auto = 1 // Discord chooses quality for optimal performance
    case full = 2 // 720p
}

public enum ChannelType: Int, Codable {
    case text = 0
    case dm = 1 // swiftlint:disable:this identifier_name
    case voice = 2
    case groupDM = 3
    case category = 4
    case news = 5
    case store = 6 // Depreciated game-selling channel
    case newsThread = 10
    case publicThread = 11
    case privateThread = 12
    case stageVoice = 13
    case directory = 14 // Hubs
    case forum = 15 // A channel that can only contain threads
    case media = 16 // A forum-like channel focused on media posts

    case unknown = -1 // An unknown value

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = Self(rawValue: try container.decode(Int.self)) ?? Self.unknown
    }

    public var isThread: Bool {
        switch self {
        case .newsThread, .publicThread, .privateThread: return true
        default: return false
        }
    }

    public var isDiscussion: Bool {
        self == .forum || self == .media
    }
}

public struct ChannelFlags: OptionSet, Codable, Equatable, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public init(from decoder: Decoder) throws {
        rawValue = try decoder.singleValueContainer().decode(Int.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public static let pinned = Self(rawValue: 1 << 1)
    public static let requireTag = Self(rawValue: 1 << 4)
    public static let hideMediaDownloadOptions = Self(rawValue: 1 << 15)
}

public enum ForumSortOrder: Int, Codable, Equatable, Sendable {
    case latestActivity = 0
    case creationDate = 1
}

public struct ForumTag: Codable, Identifiable, Equatable, Sendable {
    public let id: Snowflake
    public let name: String
    public let moderated: Bool
    public let emoji_id: Snowflake?
    public let emoji_name: String?
}

public struct Channel: Identifiable, Codable, GatewayData, Equatable {
    public static func == (lhs: Channel, rhs: Channel) -> Bool {
        lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.topic == rhs.topic
            && lhs.position == rhs.position
            && lhs.parent_id == rhs.parent_id
            && lhs.permission_overwrites == rhs.permission_overwrites
            && lhs.last_message_id == rhs.last_message_id
            && lhs.message_count == rhs.message_count
            && lhs.member_count == rhs.member_count
            && lhs.thread_metadata == rhs.thread_metadata
            && lhs.flags == rhs.flags
            && lhs.applied_tags == rhs.applied_tags
            && lhs.available_tags == rhs.available_tags
            && lhs.default_sort_order == rhs.default_sort_order
    }

    public let id: Snowflake
    public let type: ChannelType
    public let guild_id: Snowflake?
    public let position: Int?
    public let permission_overwrites: [PermOverwrite]?
    public let name: String?
    public let topic: String?
    public let nsfw: Bool?
    public let last_message_id: Snowflake? // The id of the last message sent in this channel (may not point to an existing or valid message)
    public let bitrate: Int?
    public let user_limit: Int?
    public let rate_limit_per_user: Int?
    public let recipients: [User]?
    public let recipient_ids: [Snowflake]?
    public let icon: String? // Icon hash of group DM
    public let owner_id: Snowflake?
    public let application_id: Snowflake?
    public let parent_id: Snowflake? // ID of parent category (for channels) or parent channel (for threads)
    public let last_pin_timestamp: Date?
    public let rtc_region: String?
    public let video_quality_mode: VideoQualityMode?
    public let message_count: Int? // Approx. msg count in threads, stops counting at 50
    public let member_count: Int? // Approx. member count in threads, stops counting at 50
    public let thread_metadata: ThreadMeta?
    public let member: ThreadMember? // Thread member object for the current user, if they have joined the thread, only included on certain API endpoints
    public let default_auto_archive_duration: Int? // Default duration that the clients (not the API) will use for newly created threads, in minutes, to automatically archive the thread after recent activity, can be set to: 60, 1440, 4320, 10080
    public let permissions: Permissions? // Computed permissions for the invoking user in the channel, including overwrites, only included when part of the resolved data received on a slash command interaction
    public let flags: ChannelFlags?
    public let applied_tags: [Snowflake]?
    public let available_tags: [ForumTag]?
    public let default_sort_order: ForumSortOrder?
}

/*
 Structs for threads, which are reskinned channels that can be
 children of a channel, for small discussions and the like.
 */

public struct ThreadMeta: Codable, Equatable {
    public let archived: Bool
    public let auto_archive_duration: Int // Duration in minutes to automatically archive the thread after recent activity, can be set to: 60, 1440, 4320, 10080
    public let archive_timestamp: Date
    public let locked: Bool
    public let invitable: Bool? // Only available in private threads
    public let create_timestamp: Date? // Timestamp when the thread was created; only populated for threads created after 2022-01-09
}

public struct ThreadMember: Codable, GatewayData {
    public let id: Snowflake? // ID of thread
    public let user_id: Snowflake? // ID of user
    public let join_timestamp: Date // When user last joined thread
    public let flags: Int // Any user-thread settings, currently only used for notifications
    @DefaultFalseDecodable public var muted: Bool
    @LossyOptionalDecodable public var mute_config: UserGuildSettings.MuteConfig?
    public let guild_id: Snowflake?
    public let member: Member?
}
