import DiscordKitCore

struct GuildBanEntry: Codable {
    let reason: String
    let user: User
}