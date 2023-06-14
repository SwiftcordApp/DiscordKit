//
//  File.swift
//  
//
//  Created by Andrew Glaze on 6/4/23.
//

import Foundation
import DiscordKitCore

public class Guild {
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
    public fileprivate(set) var owner: Member
    /// The AFK Voice Channel.
    public fileprivate(set) var afkChannel: GuildChannel? = nil
    /// The number of seconds until someone is moved to the afk channel.
    public let afkTimeout: Int
    /// If the guild has widgets enabled.
    public let widgetEnabled: Bool?
    /// The widget channel in the guild.
    public fileprivate(set) var widgetChannel: GuildChannel? = nil
    /// The verification level required in the guild.
    public let verificationLevel: VerificationLevel
    /// The guild's explicit content filter.
    public let explicitContentFilter: ExplicitContentFilterLevel
    /// The list of features that the guild has.
    public let features: [GuildFeature]
    /// The guild's MFA requirement level.
    public let mfaLevel: MFALevel
    /// The guild's system message channel.
    public fileprivate(set) var systemChannel: GuildChannel? = nil
    /// The guild's rules channel.
    public fileprivate(set) var rulesChannel: GuildChannel? = nil
    /// If the guild is a "large" guild.
    public var large: Bool?
    /// if the guild is unavailable due to an outage.
    public var unavailable: Bool?
    /// The number of members in this guild, if available. May be out of date.
    /// 
    /// Note: Due to Discord API restrictions, you must have the `Intents.members` intent for this number to be up-to-date and accurate.
    public var memberCount: Int?
    /// The maximum number of members that can join this guild.
    public let maxMembers: Int?
    /// The guild's vanity URL code.
    public let vanityURLCode: String?
    /// The guild's vanity invite URL.
    public fileprivate(set) var vanityURL: URL? = nil
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
    /// The channel in the guild where mods and admins receive notices from discord.
    public fileprivate(set) var publicUpdatesChannel: GuildChannel? = nil
    /// The maximum number of users that can be in a video channel.
    public let maxVideoChannelUsers: Int?
    /// The approximate number of members in the guild. Only available in some contexts.
    public let approximateMemberCount: Int? // Approximate number of members in this guild, returned from the GET /guilds/<id> endpoint when with_counts is true
    /// The approximate number of online and active members in the guild. Only available in some contexts.
    public let approximatePresenceCount: Int? // Approximate number of non-offline members in this guild, returned from the GET /guilds/<id> endpoint when with_counts is true
    /// The guild's NSFW level.
    public let nsfwLevel: NSFWLevel
    /// The stage instances in the guild that are currently running.
    public var stageInstances: [StageInstance]?
    /// The scheduled events in the guild.
    public var scheduledEvents: [GuildScheduledEvent]?
    /// If the guild has the server boost progress bar enabled.
    public let premiumProgressBarEnabled: Bool

    internal init(guild: DiscordKitCore.Guild, rest: DiscordREST) async throws {
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
        approximateMemberCount = guild.approximate_member_count
        approximatePresenceCount = guild.approximate_presence_count
        nsfwLevel = guild.nsfw_level
        stageInstances = guild.stage_instances
        scheduledEvents = guild.guild_scheduled_events
        premiumProgressBarEnabled = guild.premium_progress_bar_enabled

        if let afk_channel_id = guild.afk_channel_id {
            afkChannel = try? await GuildChannel(from: afk_channel_id)
        }

        if let widget_channel_id = guild.widget_channel_id {
            widgetChannel = try? await GuildChannel(from: widget_channel_id)
        }

        if let rules_channel_id = guild.rules_channel_id {
            rulesChannel = try? await GuildChannel(from: rules_channel_id)
        }

        if let system_channel_id = guild.system_channel_id {
            systemChannel = try? await GuildChannel(from: system_channel_id)
        }

        if let public_updates_channel_id = guild.public_updates_channel_id {
            publicUpdatesChannel = try? await GuildChannel(from: public_updates_channel_id)
        }

        if let vanity_url_code = vanityURLCode {
            vanityURL = URL(string: "https://discord.gg/\(vanity_url_code)")
        }

        owner = try await Member(guildID: id, userID: ownerID)
    }

    /// Get a guild object from a guild ID.
    /// - Parameter id: The ID of the guild you want.
    public convenience init(id: Snowflake) async throws {
        let coreGuild = try await Client.current!.rest.getGuild(id: id)
        try await self.init(guild: coreGuild, rest: Client.current!.rest)
    }
}

public extension Guild {

}
