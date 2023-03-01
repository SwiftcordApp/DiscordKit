// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    /// Get Guild Audit Log
    ///
    /// > GET: `/guilds/{guild.id}/audit-logs`
    func getGuildAuditLog<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/audit-logs"
        )
    }
}
