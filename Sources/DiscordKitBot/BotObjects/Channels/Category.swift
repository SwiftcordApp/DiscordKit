import Foundation
import DiscordKitCore

public class CategoryChannel: GuildChannel {
    private let coreChannels: [DiscordKitCore.Channel]?
    public let channels: [GuildChannel]?
    public let textChannels: [TextChannel]?
    public let voiceChannels: [VoiceChannel]? = nil
    public let stageChannels: [StageChannel]? = nil
    public let nsfw: Bool

    override init(from channel: DiscordKitCore.Channel, rest: DiscordREST) async {
        coreChannels = try? await rest.getGuildChannels(id: channel.guild_id!).compactMap({ try? $0.result.get() })
        channels = await coreChannels?.asyncMap({ await GuildChannel(from: $0, rest: rest) })
        textChannels = await coreChannels?.asyncMap({ await TextChannel(from: $0, rest: rest) })

        nsfw = channel.nsfw ?? false
        await super.init(from: channel, rest: rest)

    }

}