//
//  File.swift
//  
//
//  Created by Andrew Glaze on 6/2/23.
//

import Foundation
import DiscordKitCore

public struct BotMember {
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
    public let user_id: Snowflake?
    
    fileprivate weak var rest: DiscordREST?
    
    internal init(from member: Member, rest: DiscordREST) {
        user = member.user
        nick = member.nick
        avatar = member.avatar
        roles = member.roles
        joined_at = member.joined_at
        premium_since = member.premium_since
        deaf = member.deaf
        mute = member.mute
        pending = member.pending
        permissions = member.permissions
        communication_disabled_until = member.communication_disabled_until
        guild_id = member.guild_id
        user_id = member.user_id

        self.rest = rest
    }
}

public extension BotMember {
    func changeNickname(_ nickname: String) async throws {
        try await rest?.editGuildMember(guild_id!, user!.id, ["nick":nickname])
    }
    
    func addRole(_ role: Snowflake) async throws {
        var roles = roles
        roles.append(role)
        try await rest?.editGuildMember(guild_id!, user!.id, ["roles":roles])
    }
}
