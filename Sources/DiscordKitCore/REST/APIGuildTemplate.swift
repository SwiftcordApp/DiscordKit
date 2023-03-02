// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    /// Get Guild Template
    ///
    /// > GET: `/guilds/templates/{template.code}`
    func getGuildTemplate<T: Decodable>(
        _ templateCode: String
    ) async throws -> T {
        return try await getReq(
            path: "guilds/templates/\(templateCode)"
        )
    }
    /// Create Guild from Guild Template
    ///
    /// > POST: `/guilds/templates/{template.code}`
    func createGuildfromGuildTemplate<T: Decodable, B: Encodable>(
        _ templateCode: String,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "guilds/templates/\(templateCode)",
            body: body
        )
    }
    /// Get Guild Templates
    ///
    /// > GET: `/guilds/{guild.id}/templates`
    func getGuildTemplates<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/templates"
        )
    }
    /// Create Guild Template
    ///
    /// > POST: `/guilds/{guild.id}/templates`
    func createGuildTemplate<T: Decodable, B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "guilds/\(guildId)/templates",
            body: body
        )
    }
    /// Sync Guild Template
    ///
    /// > PUT: `/guilds/{guild.id}/templates/{template.code}`
    func syncGuildTemplate<T: Decodable, B: Encodable>(
        _ guildId: Snowflake,
        _ templateCode: String,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "guilds/\(guildId)/templates/\(templateCode)",
            body: body
        )
    }
    /// Edit Guild Template
    ///
    /// > PATCH: `/guilds/{guild.id}/templates/{template.code}`
    func editGuildTemplate<B: Encodable>(
        _ guildId: Snowflake,
        _ templateCode: String,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/templates/\(templateCode)",
            body: body
        )
    }
    /// Delete Guild Template
    ///
    /// > DELETE: `/guilds/{guild.id}/templates/{template.code}`
    func deleteGuildTemplate(
        _ guildId: Snowflake,
        _ templateCode: String
    ) async throws {
        try await deleteReq(
            path: "guilds/\(guildId)/templates/\(templateCode)"
        )
    }
}
