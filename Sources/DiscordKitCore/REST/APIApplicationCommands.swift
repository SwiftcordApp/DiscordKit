// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    /// Get Global Application Commands
    ///
    /// > GET: `/applications/{application.id}/commands`
    func getGlobalApplicationCommands<T: Decodable>(
        _ applicationId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "applications/\(applicationId)/commands"
        )
    }
    /// Create Global Application Command
    ///
    /// > POST: `/applications/{application.id}/commands`
    func createGlobalApplicationCommand<T: Decodable, B: Encodable>(
        _ applicationId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "applications/\(applicationId)/commands",
            body: body
        )
    }
    /// Get Global Application Command
    ///
    /// > GET: `/applications/{application.id}/commands/{command.id}`
    func getGlobalApplicationCommand<T: Decodable>(
        _ applicationId: Snowflake,
        _ commandId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "applications/\(applicationId)/commands/\(commandId)"
        )
    }
    /// Edit Global Application Command
    ///
    /// > PATCH: `/applications/{application.id}/commands/{command.id}`
    func editGlobalApplicationCommand<B: Encodable>(
        _ applicationId: Snowflake,
        _ commandId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "applications/\(applicationId)/commands/\(commandId)",
            body: body
        )
    }
    /// Delete Global Application Command
    ///
    /// > DELETE: `/applications/{application.id}/commands/{command.id}`
    func deleteGlobalApplicationCommand(
        _ applicationId: Snowflake,
        _ commandId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "applications/\(applicationId)/commands/\(commandId)"
        )
    }
    /// Bulk Overwrite Global Application Commands
    ///
    /// > PUT: `/applications/{application.id}/commands`
    func bulkOverwriteGlobalApplicationCommands<T: Decodable, B: Encodable>(
        _ applicationId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "applications/\(applicationId)/commands",
            body: body
        )
    }
    /// Get Guild Application Commands
    ///
    /// > GET: `/applications/{application.id}/guilds/{guild.id}/commands`
    func getGuildApplicationCommands<T: Decodable>(
        _ applicationId: Snowflake,
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "applications/\(applicationId)/guilds/\(guildId)/commands"
        )
    }
    /// Create Guild Application Command
    ///
    /// > POST: `/applications/{application.id}/guilds/{guild.id}/commands`
    func createGuildApplicationCommand<T: Decodable, B: Encodable>(
        _ applicationId: Snowflake,
        _ guildId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "applications/\(applicationId)/guilds/\(guildId)/commands",
            body: body
        )
    }
    /// Get Guild Application Command
    ///
    /// > GET: `/applications/{application.id}/guilds/{guild.id}/commands/{command.id}`
    func getGuildApplicationCommand<T: Decodable>(
        _ applicationId: Snowflake,
        _ guildId: Snowflake,
        _ commandId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
        )
    }
    /// Edit Guild Application Command
    ///
    /// > PATCH: `/applications/{application.id}/guilds/{guild.id}/commands/{command.id}`
    func editGuildApplicationCommand<B: Encodable>(
        _ applicationId: Snowflake,
        _ guildId: Snowflake,
        _ commandId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)",
            body: body
        )
    }
    /// Delete Guild Application Command
    ///
    /// > DELETE: `/applications/{application.id}/guilds/{guild.id}/commands/{command.id}`
    func deleteGuildApplicationCommand(
        _ applicationId: Snowflake,
        _ guildId: Snowflake,
        _ commandId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
        )
    }
    /// Bulk Overwrite Guild Application Commands
    ///
    /// > PUT: `/applications/{application.id}/guilds/{guild.id}/commands`
    func bulkOverwriteGuildApplicationCommands<T: Decodable, B: Encodable>(
        _ applicationId: Snowflake,
        _ guildId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "applications/\(applicationId)/guilds/\(guildId)/commands",
            body: body
        )
    }
    /// Get Guild Application Command Permissions
    ///
    /// > GET: `/applications/{application.id}/guilds/{guild.id}/commands/permissions`
    func getGuildApplicationCommandPermissions<T: Decodable>(
        _ applicationId: Snowflake,
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "applications/\(applicationId)/guilds/\(guildId)/commands/permissions"
        )
    }
    /// Get Application Command Permissions
    ///
    /// > GET: `/applications/{application.id}/guilds/{guild.id}/commands/{command.id}/permissions`
    func getApplicationCommandPermissions<T: Decodable>(
        _ applicationId: Snowflake,
        _ guildId: Snowflake,
        _ commandId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
        )
    }
    /// Edit Application Command Permissions
    ///
    /// > PUT: `/applications/{application.id}/guilds/{guild.id}/commands/{command.id}/permissions`
    func editApplicationCommandPermissions<T: Decodable, B: Encodable>(
        _ applicationId: Snowflake,
        _ guildId: Snowflake,
        _ commandId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions",
            body: body
        )
    }
    /// Batch Edit Application Command Permissions
    ///
    /// > PUT: `/applications/{application.id}/guilds/{guild.id}/commands/permissions`
    func batchEditApplicationCommandPermissions<T: Decodable, B: Encodable>(
        _ applicationId: Snowflake,
        _ guildId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "applications/\(applicationId)/guilds/\(guildId)/commands/permissions",
            body: body
        )
    }
}
