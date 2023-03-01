// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    /// List Scheduled Events for Guild
    ///
    /// > GET: `/guilds/{guild.id}/scheduled-events`
    func listScheduledEventsforGuild<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/scheduled-events"
        )
    }
    /// Create Guild Scheduled Event
    ///
    /// > POST: `/guilds/{guild.id}/scheduled-events`
    func createGuildScheduledEvent<T: Decodable, B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "guilds/\(guildId)/scheduled-events",
            body: body
        )
    }
    /// Get Guild Scheduled Event
    ///
    /// > GET: `/guilds/{guild.id}/scheduled-events/{guild_scheduled_event.id}`
    func getGuildScheduledEvent<T: Decodable>(
        _ guildId: Snowflake,
        _ guild_scheduled_eventId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/scheduled-events/\(guild_scheduled_eventId)"
        )
    }
    /// Edit Guild Scheduled Event
    ///
    /// > PATCH: `/guilds/{guild.id}/scheduled-events/{guild_scheduled_event.id}`
    func editGuildScheduledEvent<B: Encodable>(
        _ guildId: Snowflake,
        _ guild_scheduled_eventId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/scheduled-events/\(guild_scheduled_eventId)",
            body: body
        )
    }
    /// Delete Guild Scheduled Event
    ///
    /// > DELETE: `/guilds/{guild.id}/scheduled-events/{guild_scheduled_event.id}`
    func deleteGuildScheduledEvent(
        _ guildId: Snowflake,
        _ guild_scheduled_eventId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "guilds/\(guildId)/scheduled-events/\(guild_scheduled_eventId)"
        )
    }
    /// Get Guild Scheduled Event Users
    ///
    /// > GET: `/guilds/{guild.id}/scheduled-events/{guild_scheduled_event.id}/users`
    func getGuildScheduledEventUsers<T: Decodable>(
        _ guildId: Snowflake,
        _ guild_scheduled_eventId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/scheduled-events/\(guild_scheduled_eventId)/users"
        )
    }
}
