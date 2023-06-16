import Foundation
import DiscordKitCore

/// Represents a channel in a guild, a superclass to all guild channel types.
public class GuildChannel: Identifiable {
    /// The name of the channel.
    public let name: String?
    /// The category the channel is located in, if any.
    public var category: CategoryChannel? {
        get async throws {
            if let categoryID = coreChannel.parent_id {
                return try await CategoryChannel(from: categoryID)
            }
            return nil
        }
    }
    /// When the channel was created.
    public let createdAt: Date?
    /// The guild that the channel belongs to.
    public var guild: Guild {
        get async throws {
            if let guildID = coreChannel.guild_id {
                return try await Guild(id: guildID)
            }
            throw GuildChannelError.notAGuildChannel // This should be inaccessible
        }
    }

    /// A link that opens this channel in discord.
    let jumpURL: URL
    /// A string you can put in message contents to mention the channel.
    public let mention: String
    /// The position of the channel in the Guild's channel list
    public let position: Int?
    /// Permission overwrites for this channel.
    public let overwrites: [PermOverwrite]?
    /// Whether or not the permissions for this channel are synced with the category it belongs to.
    public var permissionsSynced: Bool {
        get async throws {
            if let category = try await category {
                return coreChannel.permissions == category.coreChannel.permissions
            }
            return false
        }
    }
    /// The Type of the channel.
    public let type: ChannelType
    /// The `Snowflake` ID of the channel.
    public let id: Snowflake

    internal let rest: DiscordREST
    internal let coreChannel: DiscordKitCore.Channel

    internal init(from channel: DiscordKitCore.Channel, rest: DiscordREST) throws {
        guard channel.guild_id != nil else { throw GuildChannelError.notAGuildChannel }
        self.coreChannel = channel
        self.name = channel.name
        self.createdAt = channel.id.creationTime()
        position = channel.position
        type = channel.type
        id = channel.id
        self.rest = rest
        self.mention = "<#\(id)>"
        self.overwrites = channel.permission_overwrites
        self.jumpURL = URL(string: "https://discord.com/channels/\(channel.guild_id!)/\(id)")!
    }

    /// Initialize an Channel using an ID.
    /// - Parameter id: The `Snowflake` ID of the channel you want to get.
    /// - Throws: `GuildChannelError.NotAGuildChannel` when the channel ID points to a channel that is not in a guild.
    public convenience init(from id: Snowflake) async throws {
        let coreChannel = try await Client.current!.rest.getChannel(id: id)
        try self.init(from: coreChannel, rest: Client.current!.rest)
    }
}

public extension GuildChannel {
    /// Creates an invite to the current channel.
    /// - Parameters:
    ///   - maxAge: How long the invite should last in seconds. If it’s 0 then the invite doesn’t expire. Defaults to `0`.
    ///   - maxUsers: How many uses the invite could be used for. If it’s 0 then there are unlimited uses. Defaults to `0`.
    ///   - temporary: Denotes that the invite grants temporary membership (i.e. they get kicked after they disconnect). Defaults to `false`.
    ///   - unique: Indicates if a unique invite URL should be created. Defaults to `true`. If this is set to `False` then it will return a previously created invite.
    /// - Returns: The newly created `Invite`.
    func createInvite(maxAge: Int = 0, maxUsers: Int = 0, temporary: Bool = false, unique: Bool = false) async throws -> Invite {
        let body = CreateChannelInviteReq(max_age: maxAge, max_users: maxUsers, temporary: temporary, unique: unique)
        return try await rest.createChannelInvite(id, body)
    }

    /// Deletes the channel. See discussion for warnings.
    /// 
    /// > Warning: Deleting a guild channel cannot be undone. Use this with caution, as it is impossible to undo this action when performed on a guild channel. 
    /// > 
    /// > In contrast, when used with a private message, it is possible to undo the action by opening a private message with the recipient again.
    func delete() async throws {
        try await rest.deleteChannel(id: id)
    }

    /// Gets all the invites for the current channel.
    /// - Returns: An Array of `Invite`s for the current channel.
    func invites() async throws -> [Invite] {
        return try await rest.getChannelInvites(id)
    }

    /// Clones a channel, with the only difference being the name.
    /// - Parameter name: The name of the cloned channel.
    /// - Returns: The newly cloned channel.
    func clone(name: String) async throws -> GuildChannel {
        let body = CreateGuildChannelRed(name: name, type: coreChannel.type, topic: coreChannel.topic, bitrate: coreChannel.bitrate, user_limit: coreChannel.user_limit, rate_limit_per_user: coreChannel.rate_limit_per_user, position: coreChannel.position, permission_overwrites: coreChannel.permission_overwrites, parent_id: coreChannel.parent_id, nsfw: coreChannel.nsfw, rtc_region: coreChannel.rtc_region, video_quality_mode: coreChannel.video_quality_mode, default_auto_archive_duration: coreChannel.default_auto_archive_duration)
        let newCh: DiscordKitCore.Channel = try await rest.createGuildChannel(guild.id, body)
        return try GuildChannel(from: newCh, rest: rest)
    }

    /// Gets the permission overrides for a specific member.
    /// - Parameter member: The member to get overrides for.
    /// - Returns: The permission overrides for that member.
    func overridesFor(_ member: Member) -> [PermOverwrite]? {
        return overwrites?.filter({ $0.id == member.user!.id && $0.type == .member})
    }

    /// Sets the permissions for a member.
    /// - Parameters:
    ///   - member: The member to set permissions for
    ///   - allow: The permissions you want to allow, use array notation to pass multiple
    ///   - deny: The permissions you want to deny, use array notation to pass multiple
    func setPermissions(for member: Member, allow: Permissions, deny: Permissions) async throws {
        let body = EditChannelPermissionsReq(allow: allow, deny: deny, type: .member)
        try await rest.editChannelPermissions(id, member.user!.id, body)
    }
}

enum GuildChannelError: Error {
    case badChannelType
    case notAGuildChannel
}

