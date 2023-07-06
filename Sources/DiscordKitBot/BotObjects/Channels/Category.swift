import Foundation
import DiscordKitCore

/// Represents a channel category in a Guild.
public class CategoryChannel: GuildChannel {
    private var coreChannels: [DiscordKitCore.Channel] {
        get async throws {
            try await rest!.getGuildChannels(id: coreChannel.guild_id!).compactMap({ try $0.result.get() }).filter({ $0.parent_id == id })
        }
    }
    /// All the channels in the category.
    public var channels: [GuildChannel] {
        get async throws {
            return try await coreChannels.asyncMap({ try GuildChannel(from: $0, rest: rest!) })
        }
    }
    /// The text channels in the category.
    public var textChannels: [TextChannel] {
        get async throws {
            return try await coreChannels.filter({ $0.type == .text }).asyncMap({ try TextChannel(from: $0, rest: rest!) })
        }
    }
    /// The voice channels in the category.
    public var voiceChannels: [GuildChannel] {
        get async throws {
            return try await coreChannels.filter({ $0.type == .voice }).asyncMap({ try TextChannel(from: $0, rest: rest!) })
        }
    }
    /// The stage channels in the category.
    public var stageChannels: [GuildChannel] {
        get async throws {
            return try await coreChannels.filter({ $0.type == .stageVoice }).asyncMap({ try TextChannel(from: $0, rest: rest!) })
        }
    }
    /// If the category is marked as nsfw.
    public let nsfw: Bool

    override init(from channel: DiscordKitCore.Channel, rest: DiscordREST) throws {
        if channel.type != .category { throw GuildChannelError.badChannelType }
        nsfw = channel.nsfw ?? false

        try super.init(from: channel, rest: rest)
    }

    /// Get a category from it's Snowflake ID.
    /// - Parameter id: The Snowflake ID of the category.
    /// - Throws: `GuildChannelError.BadChannelType` if the ID does not correlate with a text channel.
    public convenience init(from id: Snowflake) async throws {
        let coreChannel = try await Client.current!.rest.getChannel(id: id)
        try self.init(from: coreChannel, rest: Client.current!.rest)
    }

}
