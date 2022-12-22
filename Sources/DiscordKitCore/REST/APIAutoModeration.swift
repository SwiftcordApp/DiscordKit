// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    // MARK: List Auto Moderation Rules for Guild
    // GET /guilds/${GuildId}/auto-moderation/rules
    func listAutoModerationRulesforGuild<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/auto-moderation/rules/"
        )
    }
    // MARK: Get Auto Moderation Rule
    // GET /guilds/${GuildId}/auto-moderation/rules/${Auto_moderation_ruleId}
    func getAutoModerationRule<T: Decodable>(
        _ guildId: Snowflake,
        _ auto_moderation_ruleId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/auto-moderation/rules/\(auto_moderation_ruleId)/"
        )
    }
    // MARK: Create Auto Moderation Rule
    // POST /guilds/${GuildId}/auto-moderation/rules
    func createAutoModerationRule<T: Decodable, B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "guilds/\(guildId)/auto-moderation/rules/",
            body: body
        )
    }
    // MARK: Edit Auto Moderation Rule
    // PATCH /guilds/${GuildId}/auto-moderation/rules/${Auto_moderation_ruleId}
    func editAutoModerationRule<B: Encodable>(
        _ guildId: Snowflake,
        _ auto_moderation_ruleId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/auto-moderation/rules/\(auto_moderation_ruleId)/",
            body: body
        )
    }
    // MARK: Delete Auto Moderation Rule
    // DELETE /guilds/${GuildId}/auto-moderation/rules/${Auto_moderation_ruleId}
    func deleteAutoModerationRule(
        _ guildId: Snowflake,
        _ auto_moderation_ruleId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "guilds/\(guildId)/auto-moderation/rules/\(auto_moderation_ruleId)/"
        )
    }
}
