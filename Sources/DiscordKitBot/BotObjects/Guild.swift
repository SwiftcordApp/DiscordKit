//
//  File.swift
//  
//
//  Created by Andrew Glaze on 6/4/23.
//

import Foundation
import DiscordKitCore

public class Guild: Identifiable {
    /// The guild's Snowflake ID.
    public let id: Snowflake
    /// The guild's name.
    public let name: String
    /// The guild's icon asset.
    public let icon: HashedAsset?
    /// The guild's splash asset.
    public let splash: HashedAsset?
    /// The guild's discovery splash asset.
    public let discoverySplash: HashedAsset?
    /// The ID of the guild's owner.
    public let ownerID: Snowflake
    /// The member that owns the guild.
    public var owner: Member? {
        get async throws {
            return try await Member(guildID: id, userID: ownerID)
        }
    }
    /// The time that the guild was created.
    public var createdAt: Date { id.creationTime() }
    /// The number of seconds until someone is moved to the afk channel.
    public let afkTimeout: Int
    /// If the guild has widgets enabled.
    public let widgetEnabled: Bool?

    /// The verification level required in the guild.
    public let verificationLevel: VerificationLevel
    /// The guild's explicit content filter.
    public let explicitContentFilter: ExplicitContentFilterLevel
    /// The list of features that the guild has.
    public let features: [GuildFeature]
    /// The guild's MFA requirement level.
    public let mfaLevel: MFALevel
    /// If the guild is a "large" guild.
    public let large: Bool?
    /// If the guild is unavailable due to an outage.
    public let unavailable: Bool?
    /// The number of members in this guild, if available. May be out of date.
    /// 
    /// Note: Due to Discord API restrictions, you must have the `Intents.members` intent for this number to be up-to-date and accurate.
    public let memberCount: Int?
    /// The maximum number of members that can join this guild.
    public let maxMembers: Int?
    /// The maximum number of presences for the guild.
    public let maxPresences: Int?
    /// The guild's vanity URL code.
    public let vanityURLCode: String?
    /// The guild's vanity invite URL.
    public var vanityURL: URL? {
        get {
            if let vanity_url_code = vanityURLCode {
                return URL(string: "https://discord.gg/\(vanity_url_code)")
            }
            return nil
        }
    }
    /// The guild's description.
    public let description: String?
    /// The guild's banner asset.
    public let banner: HashedAsset?
    /// The guild's boost level.
    public let premiumTier: PremiumLevel
    /// The number of boosts that the guild has.
    public let premiumSubscriptionCount: Int?
    /// The preferred locale of the guild. Defaults to `en-US`.
    public let preferredLocale: DiscordKitCore.Locale
    /// The maximum number of users that can be in a video channel.
    public let maxVideoChannelUsers: Int?
    /// The maximum number of users that can be in a stage video channel.
    public let maxStageVideoUsers: Int?
    /// The approximate number of members in the guild. Only available in some contexts.
    public let approximateMemberCount: Int? // Approximate number of members in this guild, returned from the GET /guilds/<id> endpoint when with_counts is true
    /// The approximate number of online and active members in the guild. Only available in some contexts.
    public let approximatePresenceCount: Int? // Approximate number of non-offline members in this guild, returned from the GET /guilds/<id> endpoint when with_counts is true
    /// The guild's NSFW level.
    public let nsfwLevel: NSFWLevel
    /// The stage instances in the guild that are currently running.
    public let stageInstances: [StageInstance]
    /// The scheduled events in the guild.
    public let scheduledEvents: [GuildScheduledEvent]?
    /// If the guild has the server boost progress bar enabled.
    public let premiumProgressBarEnabled: Bool

    private var coreChannels: [Channel] {
        get async throws {
            try await rest.getGuildChannels(id: id).compactMap({ try? $0.result.get() })
        }
    }
    /// The channels in this guild.
    public var channels: [GuildChannel] {
        get async throws {
            try await coreChannels.asyncCompactMap({ try? GuildChannel(from: $0, rest: rest) })
        }
    }
    /// The text channels in this guild.
    public var textChannels: [TextChannel] {
        get async throws {
            try await coreChannels.filter({ $0.type == .text }).asyncCompactMap({ try? TextChannel(from: $0, rest: rest) })
        }
    }
    /// The voice channels in the guild.
    public var voiceChannels: [GuildChannel] {
        get async throws {
            try await coreChannels.filter({ $0.type == .voice }).asyncCompactMap({ try? GuildChannel(from: $0, rest: rest) })
        }
    }
    /// The categories in this guild.
    public var categories: [CategoryChannel] {
        get async throws {
            try await coreChannels.filter({ $0.type == .category }).asyncCompactMap({ try? CategoryChannel(from: $0, rest: rest) })
        }
    }
    /// The forum channels in this guild.
    public var forums: [GuildChannel] {
        get async throws {
            try await coreChannels.filter({ $0.type == .forum }).asyncCompactMap({ try? GuildChannel(from: $0, rest: rest) })
        }
    }
    /// The stage channels in this guild.
    public var stages: [GuildChannel] {
        get async throws {
            try await coreChannels.filter({ $0.type == .stageVoice }).asyncCompactMap({ try? GuildChannel(from: $0, rest: rest) })
        }
    }
    /// The AFK Voice Channel.
    public var afkChannel: GuildChannel? {
        get async throws {
            if let afk_channel_id = coreGuild.afk_channel_id {
                return try await channels.first(identifiedBy: afk_channel_id)
            }
            return nil
        }
    }
    /// The widget channel in the guild.
    public var widgetChannel: GuildChannel? {
        get async throws {
            if let widget_channel_id = coreGuild.widget_channel_id {
                return try await channels.first(identifiedBy: widget_channel_id)
            }
            return nil
        }
    }
    /// The guild's rules channel.
    public var rulesChannel: GuildChannel? {
        get async throws {
            if let rules_channel_id = coreGuild.rules_channel_id {
                return try await channels.first(identifiedBy: rules_channel_id)
            }
            return nil
        }
    }
    /// The guild's system message channel.
    public var systemChannel: GuildChannel? {
        get async throws {
            if let system_channel_id = coreGuild.system_channel_id {
                return try await channels.first(identifiedBy: system_channel_id)
            }
            return nil
        }
    }
    /// The channel in the guild where mods and admins receive notices from discord.
    public var publicUpdatesChannel: GuildChannel? {
        get async throws {
            if let public_updates_channel_id = coreGuild.public_updates_channel_id {
                return try await channels.first(identifiedBy: public_updates_channel_id)
            }
            return nil
        }
    }

    private var coreMembers: PaginatedList<DiscordKitCore.Member> {
        get {
            return PaginatedList(pageFetch: { try await self.rest.listGuildMembers(self.id, $0) }, afterGetter: { $0.user!.id })
        }
    }

    /// A list of the guild's first 50 members.
    public var members: AsyncMapSequence<PaginatedList<DiscordKitCore.Member>, Member> {
        get {
            return coreMembers.map({ Member(from: $0, rest: self.rest)})
        }
    }
    /// If the guild is "chunked"
    /// 
    /// A chunked guild means that ``memberCount`` is equal to the number of members in ``members``.
    /// If this value is false, you should request for offline members.
    // public var chunked: Bool {
    //     get async throws {
    //         try await memberCount == members.count
    //     }
    // }
    public var bans: PaginatedList<GuildBanEntry> {
        get {
            return PaginatedList(pageFetch: { try await self.rest.getGuildBans(self.id, $0)}, afterGetter: { $0.user.id })
        }
    }

    /// The bot's member object.
    public var me: Member {
        get async throws {
            return Member(from: try await rest.getGuildMember(guild: id), rest: rest)
        }
    }

    private let coreGuild: DiscordKitCore.Guild
    private var rest: DiscordREST

    internal init(guild: DiscordKitCore.Guild, rest: DiscordREST) {
        self.coreGuild = guild
        self.rest = rest
        id = guild.id
        name = guild.name
        icon = guild.icon
        splash = guild.splash
        discoverySplash = guild.discovery_splash
        ownerID = guild.owner_id
        afkTimeout = guild.afk_timeout
        widgetEnabled = guild.widget_enabled
        verificationLevel = guild.verification_level
        explicitContentFilter = guild.explicit_content_filter
        features = guild.features.compactMap({ try? $0.result.get() })
        mfaLevel = guild.mfa_level
        large = guild.large
        unavailable = guild.unavailable
        memberCount = guild.member_count
        maxMembers = guild.max_members
        vanityURLCode = guild.vanity_url_code
        description = guild.description
        banner = guild.banner
        premiumTier = guild.premium_tier
        premiumSubscriptionCount = guild.premium_subscription_count
        preferredLocale = guild.preferred_locale
        maxVideoChannelUsers = guild.max_video_channel_users
        maxStageVideoUsers = guild.max_stage_video_channel_users
        approximateMemberCount = guild.approximate_member_count
        approximatePresenceCount = guild.approximate_presence_count
        nsfwLevel = guild.nsfw_level
        stageInstances = guild.stage_instances ?? []
        scheduledEvents = guild.guild_scheduled_events
        premiumProgressBarEnabled = guild.premium_progress_bar_enabled
        maxPresences = guild.max_presences
    }

    /// Get a guild object from a guild ID.
    /// - Parameter id: The ID of the guild you want.
    public convenience init(id: Snowflake) async throws {
        let coreGuild = try await Client.current!.rest.getGuild(id: id)
        self.init(guild: coreGuild, rest: Client.current!.rest)
    }
}

public extension Guild {
    /// Bans the member from the guild.
    /// - Parameters:
    ///   - userID: The Snowflake ID of the user to ban.
    ///   - messageDeleteSeconds: The number of seconds worth of messages to delete from the user in the guild. Defaults to `86400` (1 day) if no value is passed. The minimum value is `0` and the maximum value is `604800` (7 days).
    func ban(_ userID: Snowflake, deleteMessageSeconds: Int = 86400) async throws {
        try await rest.createGuildBan(id, userID, ["delete_message_seconds":deleteMessageSeconds])
    }

    /// Bans the member from the guild.
    /// - Parameters:
    ///   - userID: The Snowflake ID of the user to ban.
    ///   - deleteMessageDays: The number of days worth of messages to delete from the user in the guild. Defaults to `1` if no value is passed. The minimum value is `0` and the maximum value is `7`.
    func ban(_ userID: Snowflake, deleteMessageDays: Int = 1) async throws {
        try await rest.createGuildBan(id, userID, ["delete_message_days":deleteMessageDays])
    }

    /// Unbans a user from the guild.
    /// - Parameter userID: The Snowflake ID of the user.
    func unban(_ userID: Snowflake) async throws {
        try await rest.removeGuildBan(id, userID)
    }
}

