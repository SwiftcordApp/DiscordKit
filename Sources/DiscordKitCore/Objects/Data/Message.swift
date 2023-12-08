//
//  Message.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

/// Type of message
public enum MessageType: Int, Codable {
    /// Default text message
    case defaultMsg = 0

    /// Sent when a member joins a group DM
    case recipientAdd = 1

    /// Sent when a member is removed from a group DM
    case recipientRemove = 2

    /// Incoming call
    case call = 3

    /// Channel name changes
    case chNameChange = 4

    /// Channel icon changes
    case chIconChange = 5

    /// Pinned message add/remove
    case chPinnedMsg = 6

    /// Sent when a user joins a server
    case guildMemberJoin = 7

    case userPremiumGuildSub = 8
    case userPremiumGuildSubTier1 = 9
    case userPremiumGuildSubTier2 = 10
    case userPremiumGuildSubTier3 = 11
    case chFollowAdd = 12
    case guildDiscoveryDisqualified = 14
    case guildDiscoveryRequalified = 15
    case guildDiscoveryGraceInitial = 16
    case guildDiscoveryGraceFinal = 17
    case threadCreated = 18

    /// A message replying to another message
    case reply = 19
    case chatInputCmd = 20
    case threadStarterMsg = 21
    case guildInviteReminder = 22
    case contextMenuCmd = 23

    /// A message detailing an action taken by automod
    case autoModAct = 24

    /// The system message sent when a user purchases or renews a role subscription.
    case roleSubscriptionPurchase = 25

    /// The system message sent when a user is given an advertisement to purchase a premium tier for an application during an interaction.
    case interactionPremiumUpsell = 26

    /// The system message sent when the stage starts.
    case stageStart = 27

    /// The system message sent when the stage ends.
    case stageEnd = 28

    /// The system message sent when the stage speaker changes.
    case stageSpeaker = 29

    /// The system message sent when the stage topic changes.
    case stageTopic = 31

    /// The system message sent when an application’s premium subscription is purchased for the guild.
    case guildApplicationPremiumSubscription = 32
}

/// Represents a message sent in a channel within Discord
public class Message: Codable, GatewayData, Identifiable {
    public struct Flags: OptionSet, Codable {
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            rawValue = try container.decode(UInt8.self)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }

        public let rawValue: UInt8

        public static let crossposted = Self(rawValue: 1 << 0)
        public static let isCrosspost = Self(rawValue: 1 << 1)
        public static let suppressEmbeds = Self(rawValue: 1 << 2)
        public static let sourceMessageDeleted = Self(rawValue: 1 << 3)
        public static let urgent = Self(rawValue: 1 << 4)
        public static let hasThread = Self(rawValue: 1 << 5)
        public static let ephemeral = Self(rawValue: 1 << 6)
    }

    public init(id: Snowflake, channel_id: Snowflake, guild_id: Snowflake? = nil, author: User, member: Member? = nil, content: String, timestamp: Date, edited_timestamp: Date? = nil, tts: Bool, mention_everyone: Bool, mentions: [User], mention_roles: [Snowflake], mention_channels: [ChannelMention]? = nil, attachments: [Attachment], embeds: [Embed], reactions: [Reaction]? = nil, pinned: Bool, webhook_id: Snowflake? = nil, type: MessageType, activity: MessageActivity? = nil, application: Application? = nil, application_id: Snowflake? = nil, message_reference: MessageReference? = nil, flags: Int? = nil, referenced_message: Message? = nil, interaction: MessageInteraction? = nil, thread: Channel? = nil, components: [MessageComponent]? = nil, sticker_items: [StickerItem]? = nil) {
        self.id = id
        self.channel_id = channel_id
        self.guild_id = guild_id
        self.author = author
        self.member = member
        self.content = content
        self.timestamp = timestamp
        self.edited_timestamp = edited_timestamp
        self.tts = tts
        self.mention_everyone = mention_everyone
        self.mentions = mentions
        self.mention_roles = mention_roles
        self.mention_channels = mention_channels
        self.attachments = attachments
        self.embeds = embeds
        self.reactions = reactions
        self.pinned = pinned
        self.webhook_id = webhook_id
        self.type = type
        self.activity = activity
        self.application = application
        self.application_id = application_id
        self.message_reference = message_reference
        self.flags = flags
        self.referenced_message = referenced_message
        self.interaction = interaction
        self.thread = thread
        self.components = components
        self.sticker_items = sticker_items
    }

    /// ID of the message
    public let id: Snowflake

    /// ID of the channel the message was sent in
    public let channel_id: Snowflake

    /// ID of the guild the message was sent in
    public let guild_id: Snowflake?

    /// The author of this message (not guaranteed to be a valid user, see discussion)
    ///
    /// Will not be a valid user if the message was sent by a webhook.
    /// > The author object follows the structure of the user object,
    /// > but is only a valid user in the case where the message is generated
    /// > by a user or bot user. If the message is generated by a webhook, the
    /// > author object corresponds to the webhook's id, username, and avatar.
    /// > You can tell if a message is generated by a webhook by checking for
    /// > the webhook_id on the message object.
    public var author: User

    /// Member properties for this message's author
    public var member: Member?

    /// Contents of the message
    ///
    /// Up to 2000 characters for non-premium users.
    public var content: String

    /// When this message was sent
    public let timestamp: Date

    /// When this message was edited (or null if never)
    public var edited_timestamp: Date?

    /// If this was a TTS message
    public var tts: Bool

    /// Whether this message mentions everyone
    public var mention_everyone: Bool

    /// Users specifically mentioned in the message
    public var mentions: [User]

    /// Roles specifically mentioned in this message
    public var mention_roles: [Snowflake]

    /// Channels specifically mentioned in this message
    public var mention_channels: [ChannelMention]?

    /// Any attached files
    ///
    /// See ``Attachment`` for more details.
    public var attachments: [Attachment]

    /// Any embedded content
    ///
    /// See ``Embed`` for more details
    public var embeds: [Embed]

    /// Reactions to the message
    public var reactions: [Reaction]?
    // Nonce can either be string or int and isn't important so I'm not including it for now

    /// If this message is pinned
    public var pinned: Bool

    /// If the message is generated by a webhook, this is the webhook's ID
    ///
    /// Use this to check if the message is sent by a webhook. ``Message/author``
    /// will not be valid if this is not nil (was sent by a webhook).
    public var webhook_id: Snowflake?

    /// Type of message
    ///
    /// Refer to ``MessageType`` for possible values.
    public let type: MessageType

    /// Sent with Rich Presence-related chat embeds
    public var activity: MessageActivity?

    /// Sent with Rich Presence-related chat embeds
    public var application: Application?

    /// If the message is an Interaction or application-owned webhook, this is the ID of the application
    public var application_id: Snowflake?

    /// Data showing the source of a crosspost, channel follow add, pin, or reply message
    public var message_reference: MessageReference?

    /// Message flags
    public var flags: Int?

    /// The message associated with the message\_reference
    ///
    /// This field is only returned for messages with a type of ``MessageType/reply``
    /// or ``MessageType/threadStarterMsg``. If the message is a reply but the
    /// referenced\_message field is not present, the backend did not attempt to
    /// fetch the message that was being replied to, so its state is unknown. If
    /// the field exists but is null, the referenced message was deleted.
    ///
    /// > Currently, it is not possible to distinguish between the field being `nil`
    /// > or the field not being present. This is due to limitations with the built-in
    /// > `Decodable` type.
    public let referenced_message: Message?

    /// Present if the message is a response to an Interaction
    public var interaction: MessageInteraction?

    /// The thread that was started from this message, includes thread member object
    public var thread: Channel?

    /// Present if the message contains components like buttons, action rows, or other interactive components
    public var components: [MessageComponent]?

    /// Present  if the message contains stickers
    public var sticker_items: [StickerItem]?

    /// Present if the message is a call in DM
    public var call: CallMessageComponent?
}

/// A complete copy of ``Message`` but with most properties marked as Optional
///
/// Swift doesn't have a Optional or Partial wrapper yet :(((
///
/// Refer to ``Message`` for documentation. Used for ``Message/referenced_message``
/// and gateway message update events.
public struct PartialMessage: Codable, GatewayData {
    public let id: Snowflake
    public let channel_id: Snowflake
    public let guild_id: Snowflake?
    public let author: User?
    public let member: Member?
    public let content: String? // The message contents (up to 2000 characters)
    public let timestamp: Date?
    public let edited_timestamp: Date?
    public let tts: Bool?
    public let mention_everyone: Bool?
    public let mentions: [User]?
    public let mention_roles: [Snowflake]?
    public let mention_channels: [ChannelMention]?
    public let attachments: [Attachment]?
    public let embeds: [Embed]?
    public let reactions: [Reaction]?
    // Nonce can either be string or int and isn't important so I'm not including it for now
    public let pinned: Bool?
    public let webhook_id: Snowflake? // If the message is generated by a webhook, this is the webhook's id
    public let type: MessageType?
    public let activity: MessageActivity?
    public let application: Application?
    public let application_id: Snowflake?
    public let message_reference: MessageReference?
    public let flags: Int?
    public let referenced_message: Message?
    public let interaction: MessageInteraction?
    public let thread: Channel?
    public let components: [MessageComponent]?
    public let sticker_items: [StickerItem]?
}

// MARK: Mostly implemented message struct, missing file params
public struct OutgoingMessage: Codable {
    public let content: String // The message contents (up to 2000 characters)
    public let tts: Bool?
    public let embeds: [Embed]?
    public let embed: Embed? // Embedded rich content, depreciated in favor of embeds
    public let allowed_mentions: AllowedMentions?
    public let message_reference: MessageReference?
    public let components: [MessageComponent]?
    public let sticker_ids: [Snowflake]?
    public let flags: Int?
}

public enum MessageActivityType: Int, Codable {
    case join = 1
    case spectate = 2
    case listen = 3
    case joinRequest = 5
}

public struct MessageActivity: Codable {
    public let type: MessageActivityType
    public let party_id: String? // party_id from a Rich Presence event
}

// MARK: Reference an existing message as a reply
public struct MessageReference: Codable {
    public init(message_id: Snowflake? = nil, channel_id: Snowflake? = nil, guild_id: Snowflake? = nil, fail_if_not_exists: Bool? = nil) {
        self.message_id = message_id
        self.channel_id = channel_id
        self.guild_id = guild_id
        self.fail_if_not_exists = fail_if_not_exists
    }

    public let message_id: Snowflake? // id of the originating message
    public let channel_id: Snowflake? // id of the originating message's channel
    public let guild_id: Snowflake? // id of the originating message's guild
    public let fail_if_not_exists: Bool? // When sending, whether to error if the referenced message doesn't exist instead of sending as a normal (non-reply) message (default true)
}

public enum MessageComponentTypes: Int, Codable {
    case actionRow = 1
    case button = 2
    case selectMenu = 3
    case textInput = 4
}

/// New message component struct
///
/// > Warning: This struct is incomplete
public struct MessageComponent: Codable {
    public let type: MessageComponentTypes
}

public protocol Component: Encodable {
    var type: MessageComponentTypes { get }
}

/// Call message component
/// Representation of a call message shown in DMs
public struct CallMessageComponent: Codable {
    public let participants: [String] // If there's a missed call there will be only 1 participant.
    public let ended_timestamp: Date? // If there's an active call, this will be nil
}
