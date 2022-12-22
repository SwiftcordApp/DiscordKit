// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    // MARK: Get Global Application Commands
    // GET /applications/${ApplicationId}/commands
    func getGlobalApplicationCommands<T: Decodable>(
        _ applicationId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "applications/\(applicationId)/commands/"
        )
    }
    // MARK: Create Global Application Command
    // POST /applications/${ApplicationId}/commands
    func createGlobalApplicationCommand<T: Decodable, B: Encodable>(
        _ applicationId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "applications/\(applicationId)/commands/",
            body: body
        )
    }
    // MARK: Get Global Application Command
    // GET /applications/${ApplicationId}/commands/${CommandId}
    func getGlobalApplicationCommand<T: Decodable>(
        _ applicationId: Snowflake,
        _ commandId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "applications/\(applicationId)/commands/\(commandId)/"
        )
    }
    // MARK: Edit Global Application Command
    // PATCH /applications/${ApplicationId}/commands/${CommandId}
    func editGlobalApplicationCommand<B: Encodable>(
        _ applicationId: Snowflake,
        _ commandId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "applications/\(applicationId)/commands/\(commandId)/",
            body: body
        )
    }
    // MARK: Delete Global Application Command
    // DELETE /applications/${ApplicationId}/commands/${CommandId}
    func deleteGlobalApplicationCommand(
        _ applicationId: Snowflake,
        _ commandId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "applications/\(applicationId)/commands/\(commandId)/"
        )
    }
    // MARK: Bulk Overwrite Global Application Commands
    // PUT /applications/${ApplicationId}/commands
    func bulkOverwriteGlobalApplicationCommands<T: Decodable, B: Encodable>(
        _ applicationId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "applications/\(applicationId)/commands/",
            body: body
        )
    }
    // MARK: Get Guild Application Commands
    // GET /applications/${ApplicationId}/guilds/${GuildId}/commands
    func getGuildApplicationCommands<T: Decodable>(
        _ applicationId: Snowflake,
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "applications/\(applicationId)/guilds/\(guildId)/commands/"
        )
    }
    // MARK: Create Guild Application Command
    // POST /applications/${ApplicationId}/guilds/${GuildId}/commands
    func createGuildApplicationCommand<T: Decodable, B: Encodable>(
        _ applicationId: Snowflake,
        _ guildId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "applications/\(applicationId)/guilds/\(guildId)/commands/",
            body: body
        )
    }
    // MARK: Get Guild Application Command
    // GET /applications/${ApplicationId}/guilds/${GuildId}/commands/${CommandId}
    func getGuildApplicationCommand<T: Decodable>(
        _ applicationId: Snowflake,
        _ guildId: Snowflake,
        _ commandId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/"
        )
    }
    // MARK: Edit Guild Application Command
    // PATCH /applications/${ApplicationId}/guilds/${GuildId}/commands/${CommandId}
    func editGuildApplicationCommand<B: Encodable>(
        _ applicationId: Snowflake,
        _ guildId: Snowflake,
        _ commandId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/",
            body: body
        )
    }
    // MARK: Delete Guild Application Command
    // DELETE /applications/${ApplicationId}/guilds/${GuildId}/commands/${CommandId}
    func deleteGuildApplicationCommand(
        _ applicationId: Snowflake,
        _ guildId: Snowflake,
        _ commandId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/"
        )
    }
    // MARK: Bulk Overwrite Guild Application Commands
    // PUT /applications/${ApplicationId}/guilds/${GuildId}/commands
    func bulkOverwriteGuildApplicationCommands<T: Decodable, B: Encodable>(
        _ applicationId: Snowflake,
        _ guildId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "applications/\(applicationId)/guilds/\(guildId)/commands/",
            body: body
        )
    }
    // MARK: Get Guild Application Command Permissions
    // GET /applications/${ApplicationId}/guilds/${GuildId}/commands/permissions
    func getGuildApplicationCommandPermissions<T: Decodable>(
        _ applicationId: Snowflake,
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "applications/\(applicationId)/guilds/\(guildId)/commands/permissions/"
        )
    }
    // MARK: Get Application Command Permissions
    // GET /applications/${ApplicationId}/guilds/${GuildId}/commands/${CommandId}/permissions
    func getApplicationCommandPermissions<T: Decodable>(
        _ applicationId: Snowflake,
        _ guildId: Snowflake,
        _ commandId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions/"
        )
    }
    // MARK: Edit Application Command Permissions
    // PUT /applications/${ApplicationId}/guilds/${GuildId}/commands/${CommandId}/permissions
    func editApplicationCommandPermissions<T: Decodable, B: Encodable>(
        _ applicationId: Snowflake,
        _ guildId: Snowflake,
        _ commandId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions/",
            body: body
        )
    }
    // MARK: Batch Edit Application Command Permissions
    // PUT /applications/${ApplicationId}/guilds/${GuildId}/commands/permissions
    func batchEditApplicationCommandPermissions<T: Decodable, B: Encodable>(
        _ applicationId: Snowflake,
        _ guildId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "applications/\(applicationId)/guilds/\(guildId)/commands/permissions/",
            body: body
        )
    }
}
