import Foundation
import DiscordKitCore

/// Represents a Discord Text Channel, and contains convenience methods for working with them.
public class TextChannel: GuildChannel {
    /// The last message sent in this channel. It may not represent a valid message.
    public var lastMessage: Message? {
        get async throws {
            if let lastMessageID = lastMessageID {
                let coreMessage = try? await rest.getChannelMsg(id: coreChannel.id, msgID: lastMessageID)
                if let coreMessage = coreMessage {
                    return await Message(from: coreMessage, rest: rest)
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
    }
    /// The id of the last message sent in this channel. It may not point to a valid message.
    public let lastMessageID: Snowflake?
    /// If the channel is marked as “not safe for work” or “age restricted”.
    public let nsfw: Bool
    /// All the threads that your bot can see.
    public var threads: [TextChannel]? {
        get async throws {
            let coreThreads = try await rest.getGuildChannels(id: coreChannel.guild_id!)
                .compactMap({ try? $0.result.get() }).filter({ $0.type == .publicThread || $0.type == .privateThread })

            return try await coreThreads.asyncMap({ try TextChannel(from: $0, rest: rest) })
        }
    }
    /// The topic of the channel
    public let topic: String?
    /// The number of seconds a member must wait between sending messages in this channel. 
    /// 
    /// A value of 0 denotes that it is disabled. 
    /// Bots and users with manage_channels or manage_messages bypass slowmode.
    public let slowmodeDelay: Int

    internal override init(from channel: Channel, rest: DiscordREST) throws {
        if channel.type != .text { throw GuildChannelError.badChannelType }
        nsfw = channel.nsfw ?? false
        slowmodeDelay = channel.rate_limit_per_user ?? 0
        lastMessageID = channel.last_message_id

        topic = channel.topic

        try super.init(from: channel, rest: rest)

    }

    /// Initialize a TextChannel from a Snowflake ID.
    /// - Parameter id: The Snowflake ID of the channel.
    /// - Throws: `GuildChannelError.BadChannelType` if the ID does not correlate with a text channel.
    public convenience init(from id: Snowflake) async throws {
        let coreChannel = try await Client.current!.rest.getChannel(id: id)
        try self.init(from: coreChannel, rest: Client.current!.rest)
    }
}

public extension TextChannel {
    /// Gets a single message in this channel from it's `Snowflake` ID.
    /// - Parameter id: The `Snowflake` ID of the message
    /// - Returns: The ``Message`` asked for.
    func getMessage(_ id: Snowflake) async throws -> Message {
        let coreMessage = try await rest.getChannelMsg(id: self.id, msgID: id)
        return await Message(from: coreMessage, rest: rest)
    }

    /// Retrieve message history starting from the most recent message in the channel.
    /// - Parameter limit: The number of messages to retrieve. If not provided, it defaults to 50.
    /// - Returns: The last `limit` messages sent in the channel.
    func getMessageHistory(limit: Int = 50) async throws -> [Message] {
        let coreMessages = try await rest.getChannelMsgs(id: id, limit: limit)
        return await coreMessages.asyncMap({ await Message(from: $0, rest: rest) })
    }

    /// Retrieve message history surrounding a certain message.
    /// - Parameters:
    ///   - around: Retrieve messages around this message.
    ///   - limit: The number of messages to retrieve. If not provided, it defaults to 50.
    /// - Returns: An array of ``Message``s around the message provided.
    func getMessageHistory(around: Message, limit: Int = 50) async throws -> [Message] {
        let coreMessages = try await rest.getChannelMsgs(id: id, limit: limit, around: around.id)
        return await coreMessages.asyncMap({ await Message(from: $0, rest: rest) })
    }

    /// Retrieve message before after a certain message.
    /// - Parameters:
    ///   - before: Retrieve messages before this message.
    ///   - limit: The number of messages to retrieve. If not provided, it defaults to 50.
    /// - Returns: An array of ``Message``s before the message provided.
    func getMessageHistory(before: Message, limit: Int = 50) async throws -> [Message] {
        let coreMessages = try await rest.getChannelMsgs(id: id, limit: limit, before: before.id)
        return await coreMessages.asyncMap({ await Message(from: $0, rest: rest) })
    }

    /// Retrieve message after after a certain message.
    /// - Parameters:
    ///   - after: Retrieve messages after this message.
    ///   - limit: The number of messages to retrieve. If not provided, it defaults to 50.
    /// - Returns: An array of ``Message``s after the message provided
    func getMessageHistory(after: Message, limit: Int = 50) async throws -> [Message] {
        let coreMessages = try await rest.getChannelMsgs(id: id, limit: limit, after: after.id)
        return await coreMessages.asyncMap({ await Message(from: $0, rest: rest) })
    }

    /// Sends a message in the channel.
    /// - Parameter message: The message to send
    /// - Returns: The sent message.
    func send(message: NewMessage) async throws -> Message {
        let coreMessage = try await rest.createChannelMsg(message: message, id: id)
        return await Message(from: coreMessage, rest: rest)
    }

    /// Bulk delete messages in this channel.
    /// - Parameter messages: An array of ``Message``s to delete.
    func deleteMessages(messages: [Message]) async throws {
        let snowflakes = messages.map({ $0.id })
        try await rest.bulkDeleteMessages(id, ["messages": snowflakes])
    }

}
