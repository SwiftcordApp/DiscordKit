// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    // MARK: Get Sticker
    // GET /stickers/{sticker.id}
    func getSticker(id: Snowflake) async throws -> Sticker {
        return try await getReq(path: "stickers/\(id)")
    }
    // MARK: List Nitro Sticker Packs
    // GET /sticker-packs
    func listNitroStickerPacks<T: Decodable>() async throws -> T {
        return try await getReq(
            path: "sticker-packs/"
        )
    }
    // MARK: List Guild Stickers
    // GET /guilds/${GuildId}/stickers
    func listGuildStickers<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/stickers/"
        )
    }
    // MARK: Get Guild Sticker
    // GET /guilds/${GuildId}/stickers/${StickerId}
    func getGuildSticker<T: Decodable>(
        _ guildId: Snowflake,
        _ stickerId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/stickers/\(stickerId)/"
        )
    }
    // MARK: Create Guild Sticker
    // POST /guilds/${GuildId}/stickers
    func createGuildSticker<T: Decodable, B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "guilds/\(guildId)/stickers/",
            body: body
        )
    }
    // MARK: Edit Guild Sticker
    // PATCH /guilds/${GuildId}/stickers/${StickerId}
    func editGuildSticker<B: Encodable>(
        _ guildId: Snowflake,
        _ stickerId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/stickers/\(stickerId)/",
            body: body
        )
    }
    // MARK: Delete Guild Sticker
    // DELETE /guilds/${GuildId}/stickers/${StickerId}
    func deleteGuildSticker(
        _ guildId: Snowflake,
        _ stickerId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "guilds/\(guildId)/stickers/\(stickerId)/"
        )
    }
}
