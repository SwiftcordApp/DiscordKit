import Foundation
import DiscordKitCore

/// Represents a Member in a ``Guild``, and contains methods for working with them.
public class Member {
    /// The User object of this member.
    public let user: User?
    /// The member's guild nickname.
    public let nick: String?
    /// The member's profile picture.
    public let avatar: String?
    /// The Snowflake IDs of the roles that this member has.
    public let roles: [Snowflake]
    /// The time that the member joined the guild.
    public let joinedAt: Date
    /// The time that the member started boosting the guild.
    public let premiumSince: Date?
    /// If the member is deafened in the guild's VC channels.
    public let deaf: Bool
    /// if the member is muted in the guild's VC channels.
    public let mute: Bool
    /// If the member is a pending member verification.
    public let pending: Bool?
    /// The total permissions of this member in the channel, including overwrites. This is only present when handling interactions.
    public let permissions: String?
    /// The time when a member's timeout will expire, and they will be able to talk in the guild again. `nil` or a time in the past if the user is not timed out.
    public let timedOutUntil: Date?
    /// The Snowflake ID of the guild this member is a part of.
    public let guildID: Snowflake?

    fileprivate var rest: DiscordREST

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

        self.rest = rest
    }

    /// Initialize a member from a guild Snowflake ID and a user snowflake ID.
    /// - Parameters:
    ///   - guildID: The Snowflake ID of the guild the member is present in.
    ///   - userID: The Snowflake ID of the user.
    public convenience init(guildID: Snowflake, userID: Snowflake) async throws {
        let coreMember: DiscordKitCore.Member = try await Client.current!.rest.getGuildMember(guildID, userID)
        self.init(from: coreMember, rest: Client.current!.rest)
    }
}

public extension Member {
    /// Changes the nickname of this member in the guild.
    /// - Parameter nickname: The new nickname for this member.
    func changeNickname(_ nickname: String) async throws {
        try await rest.editGuildMember(guildID!, user!.id, ["nick": nickname])
    }

    /// Adds a guild role to this member.
    /// - Parameter role: The snowflake ID of the role to add.
    func addRole(_ role: Snowflake) async throws {
        var roles = roles
        roles.append(role)
        try await rest.editGuildMember(guildID!, user!.id, ["roles": roles])
    }

    /// Removes a guild role from a member.
    /// - Parameter role: The Snowflake ID of the role to remove.
    func removeRole(_ role: Snowflake) async throws {
        try await rest.removeGuildMemberRole(guildID!, user!.id, role)
    }

    /// Removes all roles from a member.
    func removeAllRoles() async throws {
        let empty: [Snowflake] = []
        try await rest.editGuildMember(guildID!, user!.id, ["roles": empty])
    }

    /// Applies a time out to a member until the specified time.
    /// - Parameter time: The time that the timeout ends.
    func timeout(time: Date) async throws {
        try await rest.editGuildMember(guildID!, user!.id, ["communication_disabled_until" : time])
    }

    /// Kicks the member from the guild.
    func kick() async throws {
        try await rest.removeGuildMember(guildID!, user!.id)
    }

    /// Bans the member from the guild.
    /// - Parameter messageDeleteSeconds: The number of seconds worth of messages to delete from the user in the guild. Defaults to `0` if not value is passed. The minimum value is `0` and the maximum value is `604800` (7 days).
    func ban(messageDeleteSeconds: Int = 0) async throws {
        try await rest.createGuildBan(guildID!, user!.id, ["delete_message_seconds":messageDeleteSeconds])
    }

    /// Deletes the ban for this member.
    func unban() async throws {
        try await rest.removeGuildBan(guildID!, user!.id)
    }

    /// Creates a DM with this user.
    ///
    /// Important: You should not use this endpoint to DM everyone in a server about something.
    /// DMs should generally be initiated by a user action. If you open a significant
    /// amount of DMs too quickly, your bot may be rate limited or blocked from opening new ones.
    /// 
    /// - Returns: The newly created DM Channel
    func createDM() async throws -> Channel {
        return try await rest.createDM(["recipient_id":user!.id])
    }
}
