import Foundation
import DiscordKitCore

public class GuildChannel {
    let name: String?
    let category: CategoryChannel? = nil
    let createdAt: Date?
    fileprivate(set) var guild: Guild? = nil
    // let jumpURL: URL
    let mention: String
    let position: Int?
    let type: ChannelType
    let id: Snowflake
    private let rest: DiscordREST

    internal init(from channel: DiscordKitCore.Channel, rest: DiscordREST) async {
        self.name = channel.name
        //self.category = channel.parent_id
        self.createdAt = channel.id.creationTime()
        if let guildID = channel.guild_id {
            self.guild = try? await Client.current?.getGuild(id: guildID)
        }
        position = channel.position
        type = channel.type
        id = channel.id
        self.rest = rest
        self.mention = "<#\(id)>"
    }

    public convenience init(from id: Snowflake) async {
        let coreChannel = try! await Client.current!.rest.getChannel(id: id)
        await self.init(from: coreChannel, rest: Client.current!.rest)
    }
}

public extension GuildChannel {
    func createInvite(maxAge: Int = 0, maxUsers: Int = 0, temporary: Bool = false, unique: Bool = false) async throws -> Invite {
        let body = CreateChannelInviteReq(max_age: maxAge, max_users: maxUsers, temporary: temporary, unique: unique)
        return try await rest.createChannelInvite(id, body)
    }

    func delete() async throws {
        try await rest.deleteChannel(id: id)
    }

    
}

