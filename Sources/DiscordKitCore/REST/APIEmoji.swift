// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    // MARK: List Guild Emojis
    // GET /guilds/${GuildId}/emojis
    func listGuildEmojis<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/emojis/"
        )
    }
    // MARK: Get Guild Emoji
    // GET /guilds/${GuildId}/emojis/${EmojiId}
    func getGuildEmoji<T: Decodable>(
        _ guildId: Snowflake,
        _ emojiId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/emojis/\(emojiId)/"
        )
    }
    // MARK: Create Guild Emoji
    // POST /guilds/${GuildId}/emojis
    func createGuildEmoji<T: Decodable, B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "guilds/\(guildId)/emojis/",
            body: body
        )
    }
    // MARK: Edit Guild Emoji
    // PATCH /guilds/${GuildId}/emojis/${EmojiId}
    func editGuildEmoji<B: Encodable>(
        _ guildId: Snowflake,
        _ emojiId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/emojis/\(emojiId)/",
            body: body
        )
    }
    // MARK: Delete Guild Emoji
    // DELETE /guilds/${GuildId}/emojis/${EmojiId}
    func deleteGuildEmoji(
        _ guildId: Snowflake,
        _ emojiId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "guilds/\(guildId)/emojis/\(emojiId)/"
        )
    }
}
