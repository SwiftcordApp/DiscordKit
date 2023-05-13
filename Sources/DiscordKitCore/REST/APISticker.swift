// NOTE: This file is auto-generated

import Foundation

private struct StickerPacks: Codable, GatewayData {
    public let sticker_packs: [StickerPack]
}

public extension DiscordREST {
    /// Get Sticker
    ///
    /// > GET: `/stickers/{sticker.id}`
    func getSticker<T: Decodable>(
        _ stickerId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "stickers/\(stickerId)"
        )
    }
    /// List Nitro Sticker Packs
    ///
    /// > GET: `/sticker-packs`
    func listNitroStickerPacks() async throws -> [StickerPack] {
        let stickerPacks: StickerPacks = try await getReq(
            path: "sticker-packs"
        )
        return stickerPacks.sticker_packs
    }
    /// List Guild Stickers
    ///
    /// > GET: `/guilds/{guild.id}/stickers`
    func listGuildStickers<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/stickers"
        )
    }
    /// Get Guild Sticker
    ///
    /// > GET: `/guilds/{guild.id}/stickers/{sticker.id}`
    func getGuildSticker<T: Decodable>(
        _ guildId: Snowflake,
        _ stickerId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/stickers/\(stickerId)"
        )
    }
    /// Create Guild Sticker
    ///
    /// > POST: `/guilds/{guild.id}/stickers`
    func createGuildSticker<T: Decodable, B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "guilds/\(guildId)/stickers",
            body: body
        )
    }
    /// Edit Guild Sticker
    ///
    /// > PATCH: `/guilds/{guild.id}/stickers/{sticker.id}`
    func editGuildSticker<B: Encodable>(
        _ guildId: Snowflake,
        _ stickerId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/stickers/\(stickerId)",
            body: body
        )
    }
    /// Delete Guild Sticker
    ///
    /// > DELETE: `/guilds/{guild.id}/stickers/{sticker.id}`
    func deleteGuildSticker(
        _ guildId: Snowflake,
        _ stickerId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "guilds/\(guildId)/stickers/\(stickerId)"
        )
    }
}
