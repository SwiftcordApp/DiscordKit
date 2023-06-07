//
//  File.swift
//  
//
//  Created by Andrew Glaze on 6/2/23.
//

import Foundation
import DiscordKitCore

public struct Member {
    public let user: User?
    public let nick: String?
    public let avatar: String?
    public let roles: [Snowflake]
    public let joinedAt: Date
    public let premiumSince: Date? // When the user started boosting the guild
    public let deaf: Bool
    public let mute: Bool
    public let pending: Bool?
    public let permissions: String? // Total permissions of the member in the channel, including overwrites, returned when in the interaction object
    public let timedOutUntil: Date? // When the user's timeout will expire and the user will be able to communicate in the guild again, null or a time in the past if the user is not timed out
    public let guildID: Snowflake?
    public let userID: Snowflake?

    fileprivate weak var rest: DiscordREST?

    internal init(from member: DiscordKitCore.Member, rest: DiscordREST) {
        user = member.user
        nick = member.nick
        avatar = member.avatar
        roles = member.roles
        joinedAt = member.joined_at
        premiumSince = member.premium_since
        deaf = member.deaf
        mute = member.mute
        pending = member.pending
        permissions = member.permissions
        timedOutUntil = member.communication_disabled_until
        guildID = member.guild_id
        userID = member.user_id

        self.rest = rest
    }
}

public extension Member {
    func changeNickname(_ nickname: String) async throws {
        try await rest?.editGuildMember(guildID!, user!.id, ["nick": nickname])
    }

    func addRole(_ role: Snowflake) async throws {
        var roles = roles
        roles.append(role)
        try await rest?.editGuildMember(guildID!, user!.id, ["roles": roles])
    }

    func removeRole(_ role: Snowflake) async throws {
        try await rest!.removeGuildMemberRole(guildID!, user!.id, role)
    }

    func timeout(time: Date) async throws {
        try await rest!.editGuildMember(guildID!, user!.id, ["communication_disabled_until" : time])
    }

    func kick() async throws {
        try await rest!.removeGuildMember(guildID!, user!.id)
    }

    func ban(messageDeleteSeconds: Int = 0) async throws {
        try await rest!.createGuildBan(guildID!, user!.id, ["delete_message_seconds":messageDeleteSeconds])
    }

    func unban() async throws {
        try await rest!.removeGuildBan(guildID!, user!.id)
    }

    /// Creates a DM with this user.
    ///
    /// Important: You should not use this endpoint to DM everyone in a server about something.
    /// DMs should generally be initiated by a user action. If you open a significant
    /// amount of DMs too quickly, your bot may be rate limited or blocked from opening new ones.
    /// 
    /// - Returns: The DM ``Channel``
    func createDM() async throws -> Channel {
        return try await rest!.createDM(["recipient_id":user!.id])
    }
}
