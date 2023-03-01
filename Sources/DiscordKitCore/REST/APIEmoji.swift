// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    /// List Guild Emojis
    ///
    /// > GET: `/guilds/{guild.id}/emojis`
    func listGuildEmojis<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/emojis"
        )
    }
    /// Get Guild Emoji
    ///
    /// > GET: `/guilds/{guild.id}/emojis/{emoji.id}`
    func getGuildEmoji<T: Decodable>(
        _ guildId: Snowflake,
        _ emojiId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/emojis/\(emojiId)"
        )
    }
    /// Create Guild Emoji
    ///
    /// > POST: `/guilds/{guild.id}/emojis`
    func createGuildEmoji<T: Decodable, B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "guilds/\(guildId)/emojis",
            body: body
        )
    }
    /// Edit Guild Emoji
    ///
    /// > PATCH: `/guilds/{guild.id}/emojis/{emoji.id}`
    func editGuildEmoji<B: Encodable>(
        _ guildId: Snowflake,
        _ emojiId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/emojis/\(emojiId)",
            body: body
        )
    }
    /// Delete Guild Emoji
    ///
    /// > DELETE: `/guilds/{guild.id}/emojis/{emoji.id}`
    func deleteGuildEmoji(
        _ guildId: Snowflake,
        _ emojiId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "guilds/\(guildId)/emojis/\(emojiId)"
        )
    }
}
