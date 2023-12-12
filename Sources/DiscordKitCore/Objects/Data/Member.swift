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
    public let avatar: String?
    public let roles: [Snowflake]
    public let joined_at: Date
    public let premium_since: Date? // When the user started boosting the guild
    public let deaf: Bool
    public let mute: Bool
    public let pending: Bool?
    public let permissions: String? // Total permissions of the member in the channel, including overwrites, returned when in the interaction object
    public let communication_disabled_until: Date? // When the user's timeout will expire and the user will be able to communicate in the guild again, null or a time in the past if the user is not timed out
    public let guild_id: Snowflake?
    public let user_id: Snowflake? // Only present in merged_members in READY payload!

    public init(from updateMember: GuildMemberUpdate, merging: Self? = nil) {
        self.user = updateMember.user
        self.nick = updateMember.nick
        self.avatar = updateMember.avatar
        self.roles = updateMember.roles
        self.joined_at = merging?.joined_at ?? updateMember.joined_at ?? .distantPast
        self.premium_since = updateMember.premium_since
        self.deaf = merging?.deaf ?? updateMember.deaf ?? false
        self.mute = merging?.mute ?? updateMember.mute ?? false
        self.pending = updateMember.pending
        self.permissions = merging?.permissions
        self.communication_disabled_until = updateMember.communication_disabled_until
        self.guild_id = updateMember.guild_id
        self.user_id = merging?.user_id
    }
}
