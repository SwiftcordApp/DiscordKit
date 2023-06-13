import Foundation
import DiscordKitCore

public class TextChannel: GuildChannel {
    let lastMessage: Message?
    let lastMessageID: Snowflake?
    // fileprivate(set) var members: [Member]? = nil
    let nsfw: Bool
    fileprivate(set) var threads: [TextChannel]? = nil
    let topic: String?
    private let rest: DiscordREST

    internal override init(from channel: Channel, rest: DiscordREST) async {
        nsfw = channel.nsfw ?? false

        lastMessageID = channel.last_message_id
        if let lastMessageID = lastMessageID {
            let coreMessage = try? await rest.getChannelMsg(id: channel.id, msgID: lastMessageID)
            if let coreMessage = coreMessage {
                lastMessage = await Message(from: coreMessage, rest: rest)
            } else {
                lastMessage = nil
            }
        } else {
            lastMessage = nil
        }

        topic = channel.topic

        let coreThreads = try? await rest.getGuildChannels(id: channel.guild_id!)
            .compactMap({ try? $0.result.get() }).filter({ $0.type == .publicThread || $0.type == .privateThread })

        threads = await coreThreads!.asyncMap({ await TextChannel(from: $0, rest: rest) })

        self.rest = rest

        await super.init(from: channel, rest: rest)

    }

    public convenience init(from id: Snowflake) async {
        let coreChannel = try! await Client.current!.rest.getChannel(id: id)
        await self.init(from: coreChannel, rest: Client.current!.rest)
    }
}

public extension TextChannel {
    func getMessages(limit: Int = 50) async throws -> [Message] {
        let coreMessages = try await rest.getChannelMsgs(id: id, limit: limit)
        return await coreMessages.asyncMap({ await Message(from: $0, rest: rest) })
    }

    func getMessages(around: Message, limit: Int = 50) async throws -> [Message] {
        let coreMessages = try await rest.getChannelMsgs(id: id, limit: limit, around: around.id)
        return await coreMessages.asyncMap({ await Message(from: $0, rest: rest) })
    }

    func getMessages(before: Message, limit: Int = 50) async throws -> [Message] {
        let coreMessages = try await rest.getChannelMsgs(id: id, limit: limit, before: before.id)
        return await coreMessages.asyncMap({ await Message(from: $0, rest: rest) })
    }

    func getMessages(after: Message, limit: Int = 50) async throws -> [Message] {
        let coreMessages = try await rest.getChannelMsgs(id: id, limit: limit, after: after.id)
        return await coreMessages.asyncMap({ await Message(from: $0, rest: rest) })
    }

    func send(message: NewMessage) async throws -> Message {
        let coreMessage = try await rest.createChannelMsg(message: message, id: id)
        return await Message(from: coreMessage, rest: rest)
    }

    func deleteMessages(messages: [Message]) async throws {
        let snowflakes = messages.map({ $0.id })
        try await rest.bulkDeleteMessages(id, ["messages":snowflakes])
    }

}