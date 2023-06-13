import Foundation
import DiscordKitCore

public class CategoryChannel: GuildChannel {
    private let coreChannels: [DiscordKitCore.Channel]?
    public let channels: [GuildChannel]?
    public let textChannels: [TextChannel]?
    public let voiceChannels: [VoiceChannel]? = nil
    public let stageChannels: [StageChannel]? = nil
    public let nsfw: Bool

    override init(from channel: DiscordKitCore.Channel, rest: DiscordREST) async throws {
        coreChannels = try await rest.getGuildChannels(id: channel.guild_id!).compactMap({ try $0.result.get() })
        channels = try await coreChannels?.asyncMap({ try await GuildChannel(from: $0, rest: rest) })
        textChannels = try await coreChannels?.asyncMap({ try await TextChannel(from: $0, rest: rest) })
        nsfw = channel.nsfw ?? false

        try await super.init(from: channel, rest: rest)
    }

    convenience init(from id: Snowflake) async throws {
        let coreChannel = try await Client.current!.rest.getChannel(id: id)
        try await self.init(from: coreChannel, rest: Client.current!.rest)
    }

}