// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    // MARK: Get Guild Template
    // GET /guilds/templates/${TemplateCode}
    func getGuildTemplate<T: Decodable>(
        _ templateCode: String
    ) async throws -> T {
        return try await getReq(
            path: "guilds/templates/\(templateCode)/"
        )
    }
    // MARK: Create Guild from Guild Template
    // POST /guilds/templates/${TemplateCode}
    func createGuildfromGuildTemplate<T: Decodable, B: Encodable>(
        _ templateCode: String,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "guilds/templates/\(templateCode)/",
            body: body
        )
    }
    // MARK: Get Guild Templates
    // GET /guilds/${GuildId}/templates
    func getGuildTemplates<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/templates/"
        )
    }
    // MARK: Create Guild Template
    // POST /guilds/${GuildId}/templates
    func createGuildTemplate<T: Decodable, B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "guilds/\(guildId)/templates/",
            body: body
        )
    }
    // MARK: Sync Guild Template
    // PUT /guilds/${GuildId}/templates/${TemplateCode}
    func syncGuildTemplate<T: Decodable, B: Encodable>(
        _ guildId: Snowflake,
        _ templateCode: String,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "guilds/\(guildId)/templates/\(templateCode)/",
            body: body
        )
    }
    // MARK: Edit Guild Template
    // PATCH /guilds/${GuildId}/templates/${TemplateCode}
    func editGuildTemplate<B: Encodable>(
        _ guildId: Snowflake,
        _ templateCode: String,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/templates/\(templateCode)/",
            body: body
        )
    }
    // MARK: Delete Guild Template
    // DELETE /guilds/${GuildId}/templates/${TemplateCode}
    func deleteGuildTemplate(
        _ guildId: Snowflake,
        _ templateCode: String
    ) async throws {
        try await deleteReq(
            path: "guilds/\(guildId)/templates/\(templateCode)/"
        )
    }
}
