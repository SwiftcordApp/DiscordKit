import DiscordKitCore

public struct GuildBanEntry: Codable {
    let reason: String?
    let user: User
}
