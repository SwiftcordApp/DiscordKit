import Foundation
import DiscordKitCore

/// Represents a channel category in a Guild.
public class CategoryChannel: GuildChannel {
    private let coreChannels: [DiscordKitCore.Channel]?
    /// All the channels in the category.
    public let channels: [GuildChannel]?
    /// The text channels in the category.
    public let textChannels: [TextChannel]?
    // public let voiceChannels: [VoiceChannel]? = nil
    // public let stageChannels: [StageChannel]? = nil
    /// If the category is marked as nsfw.
    public let nsfw: Bool

    override init(from channel: DiscordKitCore.Channel, rest: DiscordREST) async throws {
        if channel.type != .category {
            throw GuildChannelError.BadChannelType
        }
        coreChannels = try await rest.getGuildChannels(id: channel.guild_id!).compactMap({ try $0.result.get() })
        channels = try await coreChannels?.asyncMap({ try await GuildChannel(from: $0, rest: rest) })
        textChannels = try await coreChannels?.asyncMap({ try await TextChannel(from: $0, rest: rest) })
        nsfw = channel.nsfw ?? false

        try await super.init(from: channel, rest: rest)
    }

    /// Get a category from it's Snowflake ID.
    /// - Parameter id: The Snowflake ID of the category.
    /// - Throws: `GuildChannelError.BadChannelType` if the ID does not correlate with a text channel.
    public convenience init(from id: Snowflake) async throws {
        let coreChannel = try await Client.current!.rest.getChannel(id: id)
        try await self.init(from: coreChannel, rest: Client.current!.rest)
    }

}