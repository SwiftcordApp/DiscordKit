//
//  File.swift
//  
//
//  Created by Andrew Glaze on 6/4/23.
//

import Foundation
import DiscordKitCore

public struct BotGuild {
    public let id: Snowflake
    public let name: String
    public let icon: HashedAsset? // Icon hash
    public let splash: String? // Splash hash
    public let discovery_splash: String?
    public let owner_id: Snowflake
    public let permissions: String?
    public let region: String? // Voice region id for the guild (deprecated)
    public let afk_channel_id: Snowflake?
    public let afk_timeout: Int
    public let widget_enabled: Bool?
    public let widget_channel_id: Snowflake?
    public let verification_level: VerificationLevel
    public let explicit_content_filter: ExplicitContentFilterLevel
    public let features: [DecodableThrowable<GuildFeature>]
    public let mfa_level: MFALevel
    public let application_id: Snowflake? // For bot-created guilds
    public let system_channel_id: Snowflake? // ID of channel for system-created messages
    public let rules_channel_id: Snowflake?
    public var joined_at: Date?
    public var large: Bool?
    public var unavailable: Bool? // If guild is unavailable due to an outage
    public var member_count: Int?
    public var voice_states: [VoiceState]?
    public var presences: [PresenceUpdate]?
    public let max_members: Int?
    public let vanity_url_code: String?
    public let description: String?
    public let banner: HashedAsset? // Banner hash
    public let premium_tier: PremiumLevel
    public let premium_subscription_count: Int? // Number of server boosts
    public let preferred_locale: DiscordKitCore.Locale // Defaults to en-US
    public let public_updates_channel_id: Snowflake?
    public let max_video_channel_users: Int?
    public let approximate_member_count: Int? // Approximate number of members in this guild, returned from the GET /guilds/<id> endpoint when with_counts is true
    public let approximate_presence_count: Int? // Approximate number of non-offline members in this guild, returned from the GET /guilds/<id> endpoint when with_counts is true
    public let nsfw_level: NSFWLevel
    public var stage_instances: [StageInstance]?
    public var guild_scheduled_events: [GuildScheduledEvent]?
    public let premium_progress_bar_enabled: Bool

    public init(_ guild: Guild) {
        id = guild.id
        name = guild.name
        icon = guild.icon
        splash = guild.splash
        discovery_splash = guild.discovery_splash
        owner_id = guild.owner_id
        permissions = guild.permissions
        region = guild.region
        afk_channel_id = guild.afk_channel_id
        afk_timeout = guild.afk_timeout
        widget_enabled = guild.widget_enabled
        widget_channel_id = guild.widget_channel_id
        verification_level = guild.verification_level
        explicit_content_filter = guild.explicit_content_filter
        features = guild.features
        mfa_level = guild.mfa_level
        application_id = guild.application_id
        system_channel_id = guild.system_channel_id
        rules_channel_id = guild.rules_channel_id
        joined_at = guild.joined_at
        large = guild.large
        unavailable = guild.unavailable
        member_count = guild.member_count
        voice_states = guild.voice_states
        presences = guild.presences
        max_members = guild.max_members
        vanity_url_code = guild.vanity_url_code
        description = guild.description
        banner = guild.banner
        premium_tier = guild.premium_tier
        premium_subscription_count = guild.premium_subscription_count
        preferred_locale = guild.preferred_locale
        public_updates_channel_id = guild.public_updates_channel_id
        max_video_channel_users = guild.max_video_channel_users
        approximate_member_count = guild.approximate_member_count
        approximate_presence_count = guild.approximate_presence_count
        nsfw_level = guild.nsfw_level
        stage_instances = guild.stage_instances
        guild_scheduled_events = guild.guild_scheduled_events
        premium_progress_bar_enabled = guild.premium_progress_bar_enabled
    }
}

public extension BotGuild {
    
}
