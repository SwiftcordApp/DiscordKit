// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    /// List Auto Moderation Rules for Guild
    ///
    /// > GET: `/guilds/{guild.id}/auto-moderation/rules`
    func listAutoModerationRulesforGuild<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/auto-moderation/rules"
        )
    }
    /// Get Auto Moderation Rule
    ///
    /// > GET: `/guilds/{guild.id}/auto-moderation/rules/{auto_moderation_rule.id}`
    func getAutoModerationRule<T: Decodable>(
        _ guildId: Snowflake,
        _ auto_moderation_ruleId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/auto-moderation/rules/\(auto_moderation_ruleId)"
        )
    }
    /// Create Auto Moderation Rule
    ///
    /// > POST: `/guilds/{guild.id}/auto-moderation/rules`
    func createAutoModerationRule<T: Decodable, B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "guilds/\(guildId)/auto-moderation/rules",
            body: body
        )
    }
    /// Edit Auto Moderation Rule
    ///
    /// > PATCH: `/guilds/{guild.id}/auto-moderation/rules/{auto_moderation_rule.id}`
    func editAutoModerationRule<B: Encodable>(
        _ guildId: Snowflake,
        _ auto_moderation_ruleId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/auto-moderation/rules/\(auto_moderation_ruleId)",
            body: body
        )
    }
    /// Delete Auto Moderation Rule
    ///
    /// > DELETE: `/guilds/{guild.id}/auto-moderation/rules/{auto_moderation_rule.id}`
    func deleteAutoModerationRule(
        _ guildId: Snowflake,
        _ auto_moderation_ruleId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "guilds/\(guildId)/auto-moderation/rules/\(auto_moderation_ruleId)"
        )
    }
}
