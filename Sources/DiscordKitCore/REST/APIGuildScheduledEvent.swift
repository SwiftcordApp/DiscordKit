// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    // MARK: List Scheduled Events for Guild
    // GET /guilds/${GuildId}/scheduled-events
    func listScheduledEventsforGuild<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/scheduled-events/"
        )
    }
    // MARK: Create Guild Scheduled Event
    // POST /guilds/${GuildId}/scheduled-events
    func createGuildScheduledEvent<T: Decodable, B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "guilds/\(guildId)/scheduled-events/",
            body: body
        )
    }
    // MARK: Get Guild Scheduled Event
    // GET /guilds/${GuildId}/scheduled-events/${Guild_scheduled_eventId}
    func getGuildScheduledEvent<T: Decodable>(
        _ guildId: Snowflake,
        _ guild_scheduled_eventId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/scheduled-events/\(guild_scheduled_eventId)/"
        )
    }
    // MARK: Edit Guild Scheduled Event
    // PATCH /guilds/${GuildId}/scheduled-events/${Guild_scheduled_eventId}
    func editGuildScheduledEvent<B: Encodable>(
        _ guildId: Snowflake,
        _ guild_scheduled_eventId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/scheduled-events/\(guild_scheduled_eventId)/",
            body: body
        )
    }
    // MARK: Delete Guild Scheduled Event
    // DELETE /guilds/${GuildId}/scheduled-events/${Guild_scheduled_eventId}
    func deleteGuildScheduledEvent(
        _ guildId: Snowflake,
        _ guild_scheduled_eventId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "guilds/\(guildId)/scheduled-events/\(guild_scheduled_eventId)/"
        )
    }
    // MARK: Get Guild Scheduled Event Users
    // GET /guilds/${GuildId}/scheduled-events/${Guild_scheduled_eventId}/users
    func getGuildScheduledEventUsers<T: Decodable>(
        _ guildId: Snowflake,
        _ guild_scheduled_eventId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/scheduled-events/\(guild_scheduled_eventId)/users/"
        )
    }
}
