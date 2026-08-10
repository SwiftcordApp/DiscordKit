//
//  Member.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

public struct Member: Codable, GatewayData {
    public let user: User?
    public let nick: String?
    public let avatar: HashedAsset<GuildMemberAvatar>?
    public let banner: HashedAsset<GuildMemberBanner>?
    public let roles: [Snowflake]
    @DefaultDistantPastDateDecodable public var joined_at: Date
    public let premium_since: Date? // When the user started boosting the guild
    @DefaultFalseDecodable public var deaf: Bool
    @DefaultFalseDecodable public var mute: Bool
    public let pending: Bool?
    public let permissions: String? // Total permissions of the member in the channel, including overwrites, returned when in the interaction object
    public let communication_disabled_until: Date? // When the user's timeout will expire and the user will be able to communicate in the guild again, null or a time in the past if the user is not timed out
    public let flags: Flags?
    public let guild_id: Snowflake?
    public let user_id: Snowflake? // Only present in merged_members in READY payload!
    public let collectibles: UserCollectibles?
    /// Presence nested in this member, only present in ``GuildMemberListUpdate`` items
    public let presence: PresenceUpdate?

    init(
        user: User?,
        nick: String?,
        avatar: HashedAsset<GuildMemberAvatar>?,
        banner: HashedAsset<GuildMemberBanner>?,
        roles: [Snowflake],
        joined_at: Date,
        premium_since: Date?,
        deaf: Bool,
        mute: Bool,
        pending: Bool?,
        permissions: String?,
        communication_disabled_until: Date?,
        flags: Flags? = nil,
        guild_id: Snowflake?,
        user_id: Snowflake?,
        collectibles: UserCollectibles? = nil,
        presence: PresenceUpdate? = nil
    ) {
        self.user = user
        self.nick = nick
        self.avatar = avatar
        self.banner = banner
        self.roles = roles
        _joined_at = DefaultDistantPastDateDecodable(wrappedValue: joined_at)
        self.premium_since = premium_since
        _deaf = DefaultFalseDecodable(wrappedValue: deaf)
        _mute = DefaultFalseDecodable(wrappedValue: mute)
        self.pending = pending
        self.permissions = permissions
        self.communication_disabled_until = communication_disabled_until
        self.flags = flags
        self.guild_id = guild_id
        self.user_id = user_id
        self.collectibles = collectibles
        self.presence = presence
    }

    public init(from updateMember: GuildMemberUpdate, merging: Self? = nil) {
        self.user = updateMember.user
        self.nick = updateMember.nick
        self.avatar = updateMember.avatar
        self.banner = updateMember.banner
        self.roles = updateMember.roles
        _joined_at = DefaultDistantPastDateDecodable(
            wrappedValue: merging?.joined_at ?? updateMember.joined_at ?? .distantPast
        )
        self.premium_since = updateMember.premium_since
        _deaf = DefaultFalseDecodable(wrappedValue: merging?.deaf ?? updateMember.deaf ?? false)
        _mute = DefaultFalseDecodable(wrappedValue: merging?.mute ?? updateMember.mute ?? false)
        self.pending = updateMember.pending
        self.permissions = merging?.permissions
        self.communication_disabled_until = updateMember.communication_disabled_until
        self.flags = updateMember.flags ?? merging?.flags
        self.guild_id = updateMember.guild_id
        self.user_id = merging?.user_id
        self.collectibles = updateMember.collectibles ?? merging?.collectibles
        self.presence = merging?.presence
    }

    /// Returns a member whose independently cached fields retain richer existing values.
    public func preservingCachedFields(from existing: Self?, resolvedUser: User? = nil) -> Self {
        return Self(
            user: resolvedUser ?? user,
            nick: nick,
            avatar: avatar,
            banner: banner,
            roles: roles,
            joined_at: joined_at,
            premium_since: premium_since,
            deaf: deaf,
            mute: mute,
            pending: pending,
            permissions: permissions,
            communication_disabled_until: communication_disabled_until,
            flags: flags ?? existing?.flags,
            guild_id: guild_id,
            user_id: user_id,
            collectibles: collectibles ?? existing?.collectibles,
            presence: presence
        )
    }
}
