// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    /// Get Guild
    ///
    /// > GET: `/guilds/{guild.id}`
    func getGuild(id: Snowflake) async throws -> Guild {
        return try await getReq(path: "guilds/\(id)")
    }

    /// Get Guild Channels
    ///
    /// > GET: `/guilds/{guild.id}/channels`
    func getGuildChannels(id: Snowflake) async throws -> [DecodableThrowable<Channel>] {
        return try await getReq(path: "guilds/\(id)/channels")
    }

    /// Get Guild Roles
    ///
    /// > GET: `/guilds/{guild.id}/roles`
    func getGuildRoles(id: Snowflake) async throws -> [Role] {
        return try await getReq(path: "guilds/\(id)/roles")
    }
    /// Create Guild
    ///
    /// > POST: `/guilds`
    func createGuild<T: Decodable, B: Encodable>(_ body: B) async throws -> T {
        return try await postReq(
            path: "guilds",
            body: body
        )
    }
    /// Get Guild Preview
    ///
    /// > GET: `/guilds/{guild.id}/preview`
    func getGuildPreview<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/preview"
        )
    }
    /// Edit Guild
    ///
    /// > PATCH: `/guilds/{guild.id}`
    func editGuild<B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)",
            body: body
        )
    }
    /// Delete Guild
    ///
    /// > DELETE: `/guilds/{guild.id}`
    func deleteGuild(
        _ guildId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "guilds/\(guildId)"
        )
    }
    /// Create Guild Channel
    ///
    /// > POST: `/guilds/{guild.id}/channels`
    func createGuildChannel<T: Decodable, B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "guilds/\(guildId)/channels",
            body: body
        )
    }
    /// Edit Guild Channel Positions
    ///
    /// > PATCH: `/guilds/{guild.id}/channels`
    func editGuildChannelPositions<B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/channels",
            body: body
        )
    }
    /// List Active Guild Threads
    ///
    /// > GET: `/guilds/{guild.id}/threads/active`
    func listActiveGuildThreads<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/threads/active"
        )
    }
    /// Get Guild Member
    ///
    /// > GET: `/guilds/{guild.id}/members/{user.id}`
    func getGuildMember<T: Decodable>(
        _ guildId: Snowflake,
        _ userId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/members/\(userId)"
        )
    }
    /// List Guild Members
    ///
    /// > GET: `/guilds/{guild.id}/members`
    func listGuildMembers<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/members"
        )
    }
    /// Search Guild Members
    ///
    /// > GET: `/guilds/{guild.id}/members/search`
    func searchGuildMembers<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/members/search"
        )
    }
    /// Add Guild Member
    ///
    /// > PUT: `/guilds/{guild.id}/members/{user.id}`
    func addGuildMember<T: Decodable, B: Encodable>(
        _ guildId: Snowflake,
        _ userId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "guilds/\(guildId)/members/\(userId)",
            body: body
        )
    }
    /// Edit Guild Member
    ///
    /// > PATCH: `/guilds/{guild.id}/members/{user.id}`
    func editGuildMember<B: Encodable>(
        _ guildId: Snowflake,
        _ userId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/members/\(userId)",
            body: body
        )
    }
    /// Edit Current Member
    ///
    /// > PATCH: `/guilds/{guild.id}/members/@me`
    func editCurrentMember<B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/members/@me",
            body: body
        )
    }
    /// Edit Current User Nick
    ///
    /// > PATCH: `/guilds/{guild.id}/members/@me/nick`
    func editCurrentUserNick<B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/members/@me/nick",
            body: body
        )
    }
    /// Add Guild Member Role
    ///
    /// > PUT: `/guilds/{guild.id}/members/{user.id}/roles/{role.id}`
    func addGuildMemberRole(
        _ guildId: Snowflake,
        _ userId: Snowflake,
        _ roleId: Snowflake
    ) async throws {
        return try await putReq(
            path: "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
        )
    }
    /// Remove Guild Member Role
    ///
    /// > DELETE: `/guilds/{guild.id}/members/{user.id}/roles/{role.id}`
    func removeGuildMemberRole(
        _ guildId: Snowflake,
        _ userId: Snowflake,
        _ roleId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
        )
    }
    /// Remove Guild Member
    ///
    /// > DELETE: `/guilds/{guild.id}/members/{user.id}`
    func removeGuildMember(
        _ guildId: Snowflake,
        _ userId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "guilds/\(guildId)/members/\(userId)"
        )
    }
    /// Get Guild Bans
    ///
    /// > GET: `/guilds/{guild.id}/bans`
    func getGuildBans<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/bans"
        )
    }
    /// Get Guild Ban
    ///
    /// > GET: `/guilds/{guild.id}/bans/{user.id}`
    func getGuildBan<T: Decodable>(
        _ guildId: Snowflake,
        _ userId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/bans/\(userId)"
        )
    }
    /// Create Guild Ban
    ///
    /// > PUT: `/guilds/{guild.id}/bans/{user.id}`
    func createGuildBan<B: Encodable>(
        _ guildId: Snowflake,
        _ userId: Snowflake,
        _ body: B
    ) async throws {
        try await putReq(
            path: "guilds/\(guildId)/bans/\(userId)",
            body: body
        )
    }
    /// Remove Guild Ban
    ///
    /// > DELETE: `/guilds/{guild.id}/bans/{user.id}`
    func removeGuildBan(
        _ guildId: Snowflake,
        _ userId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "guilds/\(guildId)/bans/\(userId)"
        )
    }
    /// Create Guild Role
    ///
    /// > POST: `/guilds/{guild.id}/roles`
    func createGuildRole<T: Decodable, B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "guilds/\(guildId)/roles",
            body: body
        )
    }
    /// Edit Guild Role Positions
    ///
    /// > PATCH: `/guilds/{guild.id}/roles`
    func editGuildRolePositions<B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/roles",
            body: body
        )
    }
    /// Edit Guild Role
    ///
    /// > PATCH: `/guilds/{guild.id}/roles/{role.id}`
    func editGuildRole<B: Encodable>(
        _ guildId: Snowflake,
        _ roleId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/roles/\(roleId)",
            body: body
        )
    }
    /// Edit Guild MFA Level
    ///
    /// > POST: `/guilds/{guild.id}/mfa`
    func editGuildMFALevel<T: Decodable, B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "guilds/\(guildId)/mfa",
            body: body
        )
    }
    /// Delete Guild Role
    ///
    /// > DELETE: `/guilds/{guild.id}/roles/{role.id}`
    func deleteGuildRole(
        _ guildId: Snowflake,
        _ roleId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "guilds/\(guildId)/roles/\(roleId)"
        )
    }
    /// Get Guild Prune Count
    ///
    /// > GET: `/guilds/{guild.id}/prune`
    func getGuildPruneCount<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/prune"
        )
    }
    /// Begin Guild Prune
    ///
    /// > POST: `/guilds/{guild.id}/prune`
    func beginGuildPrune<T: Decodable, B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "guilds/\(guildId)/prune",
            body: body
        )
    }
    /// Get Guild Voice Regions
    ///
    /// > GET: `/guilds/{guild.id}/regions`
    func getGuildVoiceRegions<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/regions"
        )
    }
    /// Get Guild Invites
    ///
    /// > GET: `/guilds/{guild.id}/invites`
    func getGuildInvites<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/invites"
        )
    }
    /// Get Guild Integrations
    ///
    /// > GET: `/guilds/{guild.id}/integrations`
    func getGuildIntegrations<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/integrations"
        )
    }
    /// Delete Guild Integration
    ///
    /// > DELETE: `/guilds/{guild.id}/integrations/{integration.id}`
    func deleteGuildIntegration(
        _ guildId: Snowflake,
        _ integrationId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "guilds/\(guildId)/integrations/\(integrationId)"
        )
    }
    /// Get Guild Widget Settings
    ///
    /// > GET: `/guilds/{guild.id}/widget`
    func getGuildWidgetSettings<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/widget"
        )
    }
    /// Edit Guild Widget
    ///
    /// > PATCH: `/guilds/{guild.id}/widget`
    func editGuildWidget<B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/widget",
            body: body
        )
    }
    /// Get Guild Widget
    ///
    /// > GET: `/guilds/{guild.id}/widget.json`
    func getGuildWidget<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/widget.json"
        )
    }
    /// Get Guild Vanity URL
    ///
    /// > GET: `/guilds/{guild.id}/vanity-url`
    func getGuildVanityURL<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/vanity-url"
        )
    }
    /// Get Guild Widget Image
    ///
    /// > GET: `/guilds/{guild.id}/widget.png`
    func getGuildWidgetImage<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/widget.png"
        )
    }
    /// Get Guild Welcome Screen
    ///
    /// > GET: `/guilds/{guild.id}/welcome-screen`
    func getGuildWelcomeScreen<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/welcome-screen"
        )
    }
    /// Edit Guild Welcome Screen
    ///
    /// > PATCH: `/guilds/{guild.id}/welcome-screen`
    func editGuildWelcomeScreen<B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/welcome-screen",
            body: body
        )
    }
    /// Edit Current User Voice State
    ///
    /// > PATCH: `/guilds/{guild.id}/voice-states/@me`
    func editCurrentUserVoiceState<B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/voice-states/@me",
            body: body
        )
    }
    /// Edit User Voice State
    ///
    /// > PATCH: `/guilds/{guild.id}/voice-states/{user.id}`
    func editUserVoiceState<B: Encodable>(
        _ guildId: Snowflake,
        _ userId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/voice-states/\(userId)",
            body: body
        )
    }
}
