// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    // MARK: Get Guild
    // GET /guilds/{guild.id}
    func getGuild(id: Snowflake) async throws -> Guild {
        return try await getReq(path: "guilds/\(id)")
    }

    // MARK: Get Guild Channels
    // GET /guilds/{guild.id}/channels
    func getGuildChannels(id: Snowflake) async throws -> [DecodableThrowable<Channel>] {
        return try await getReq(path: "guilds/\(id)/channels")
    }

    // MARK: Get Guild Roles
    // GET /guilds/{guild.id}/roles
    func getGuildRoles(id: Snowflake) async throws -> [Role] {
        return try await getReq(path: "guilds/\(id)/roles")
    }
    // MARK: Create Guild
    // POST /guilds
    func createGuild<T: Decodable, B: Encodable>(_ body: B) async throws -> T {
        return try await postReq(
            path: "guilds/",
            body: body
        )
    }
    // MARK: Get Guild Preview
    // GET /guilds/${GuildId}/preview
    func getGuildPreview<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/preview/"
        )
    }
    // MARK: Edit Guild
    // PATCH /guilds/${GuildId}
    func editGuild<B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/",
            body: body
        )
    }
    // MARK: Delete Guild
    // DELETE /guilds/${GuildId}
    func deleteGuild(
        _ guildId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "guilds/\(guildId)/"
        )
    }
    // MARK: Create Guild Channel
    // POST /guilds/${GuildId}/channels
    func createGuildChannel<T: Decodable, B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "guilds/\(guildId)/channels/",
            body: body
        )
    }
    // MARK: Edit Guild Channel Positions
    // PATCH /guilds/${GuildId}/channels
    func editGuildChannelPositions<B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/channels/",
            body: body
        )
    }
    // MARK: List Active Guild Threads
    // GET /guilds/${GuildId}/threads/active
    func listActiveGuildThreads<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/threads/active/"
        )
    }
    // MARK: Get Guild Member
    // GET /guilds/${GuildId}/members/${UserId}
    func getGuildMember<T: Decodable>(
        _ guildId: Snowflake,
        _ userId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/members/\(userId)/"
        )
    }
    // MARK: List Guild Members
    // GET /guilds/${GuildId}/members
    func listGuildMembers<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/members/"
        )
    }
    // MARK: Search Guild Members
    // GET /guilds/${GuildId}/members/search
    func searchGuildMembers<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/members/search/"
        )
    }
    // MARK: Add Guild Member
    // PUT /guilds/${GuildId}/members/${UserId}
    func addGuildMember<T: Decodable, B: Encodable>(
        _ guildId: Snowflake,
        _ userId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "guilds/\(guildId)/members/\(userId)/",
            body: body
        )
    }
    // MARK: Edit Guild Member
    // PATCH /guilds/${GuildId}/members/${UserId}
    func editGuildMember<B: Encodable>(
        _ guildId: Snowflake,
        _ userId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/members/\(userId)/",
            body: body
        )
    }
    // MARK: Edit Current Member
    // PATCH /guilds/${GuildId}/members/@me
    func editCurrentMember<B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/members/@me/",
            body: body
        )
    }
    // MARK: Edit Current User Nick
    // PATCH /guilds/${GuildId}/members/@me/nick
    func editCurrentUserNick<B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/members/@me/nick/",
            body: body
        )
    }
    // MARK: Add Guild Member Role
    // PUT /guilds/${GuildId}/members/${UserId}/roles/${RoleId}
    func addGuildMemberRole<T: Decodable, B: Encodable>(
        _ guildId: Snowflake,
        _ userId: Snowflake,
        _ roleId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "guilds/\(guildId)/members/\(userId)/roles/\(roleId)/",
            body: body
        )
    }
    // MARK: Remove Guild Member Role
    // DELETE /guilds/${GuildId}/members/${UserId}/roles/${RoleId}
    func removeGuildMemberRole(
        _ guildId: Snowflake,
        _ userId: Snowflake,
        _ roleId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "guilds/\(guildId)/members/\(userId)/roles/\(roleId)/"
        )
    }
    // MARK: Remove Guild Member
    // DELETE /guilds/${GuildId}/members/${UserId}
    func removeGuildMember(
        _ guildId: Snowflake,
        _ userId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "guilds/\(guildId)/members/\(userId)/"
        )
    }
    // MARK: Get Guild Bans
    // GET /guilds/${GuildId}/bans
    func getGuildBans<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/bans/"
        )
    }
    // MARK: Get Guild Ban
    // GET /guilds/${GuildId}/bans/${UserId}
    func getGuildBan<T: Decodable>(
        _ guildId: Snowflake,
        _ userId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/bans/\(userId)/"
        )
    }
    // MARK: Create Guild Ban
    // PUT /guilds/${GuildId}/bans/${UserId}
    func createGuildBan<T: Decodable, B: Encodable>(
        _ guildId: Snowflake,
        _ userId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "guilds/\(guildId)/bans/\(userId)/",
            body: body
        )
    }
    // MARK: Remove Guild Ban
    // DELETE /guilds/${GuildId}/bans/${UserId}
    func removeGuildBan(
        _ guildId: Snowflake,
        _ userId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "guilds/\(guildId)/bans/\(userId)/"
        )
    }
    // MARK: Create Guild Role
    // POST /guilds/${GuildId}/roles
    func createGuildRole<T: Decodable, B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "guilds/\(guildId)/roles/",
            body: body
        )
    }
    // MARK: Edit Guild Role Positions
    // PATCH /guilds/${GuildId}/roles
    func editGuildRolePositions<B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/roles/",
            body: body
        )
    }
    // MARK: Edit Guild Role
    // PATCH /guilds/${GuildId}/roles/${RoleId}
    func editGuildRole<B: Encodable>(
        _ guildId: Snowflake,
        _ roleId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/roles/\(roleId)/",
            body: body
        )
    }
    // MARK: Edit Guild MFA Level
    // POST /guilds/${GuildId}/mfa
    func editGuildMFALevel<T: Decodable, B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "guilds/\(guildId)/mfa/",
            body: body
        )
    }
    // MARK: Delete Guild Role
    // DELETE /guilds/${GuildId}/roles/${RoleId}
    func deleteGuildRole(
        _ guildId: Snowflake,
        _ roleId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "guilds/\(guildId)/roles/\(roleId)/"
        )
    }
    // MARK: Get Guild Prune Count
    // GET /guilds/${GuildId}/prune
    func getGuildPruneCount<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/prune/"
        )
    }
    // MARK: Begin Guild Prune
    // POST /guilds/${GuildId}/prune
    func beginGuildPrune<T: Decodable, B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "guilds/\(guildId)/prune/",
            body: body
        )
    }
    // MARK: Get Guild Voice Regions
    // GET /guilds/${GuildId}/regions
    func getGuildVoiceRegions<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/regions/"
        )
    }
    // MARK: Get Guild Invites
    // GET /guilds/${GuildId}/invites
    func getGuildInvites<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/invites/"
        )
    }
    // MARK: Get Guild Integrations
    // GET /guilds/${GuildId}/integrations
    func getGuildIntegrations<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/integrations/"
        )
    }
    // MARK: Delete Guild Integration
    // DELETE /guilds/${GuildId}/integrations/${IntegrationId}
    func deleteGuildIntegration(
        _ guildId: Snowflake,
        _ integrationId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "guilds/\(guildId)/integrations/\(integrationId)/"
        )
    }
    // MARK: Get Guild Widget Settings
    // GET /guilds/${GuildId}/widget
    func getGuildWidgetSettings<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/widget/"
        )
    }
    // MARK: Edit Guild Widget
    // PATCH /guilds/${GuildId}/widget
    func editGuildWidget<B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/widget/",
            body: body
        )
    }
    // MARK: Get Guild Widget
    // GET /guilds/${GuildId}/widget.json
    func getGuildWidget<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/widget.json/"
        )
    }
    // MARK: Get Guild Vanity URL
    // GET /guilds/${GuildId}/vanity-url
    func getGuildVanityURL<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/vanity-url/"
        )
    }
    // MARK: Get Guild Widget Image
    // GET /guilds/${GuildId}/widget.png
    func getGuildWidgetImage<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/widget.png/"
        )
    }
    // MARK: Get Guild Welcome Screen
    // GET /guilds/${GuildId}/welcome-screen
    func getGuildWelcomeScreen<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/welcome-screen/"
        )
    }
    // MARK: Edit Guild Welcome Screen
    // PATCH /guilds/${GuildId}/welcome-screen
    func editGuildWelcomeScreen<B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/welcome-screen/",
            body: body
        )
    }
    // MARK: Edit Current User Voice State
    // PATCH /guilds/${GuildId}/voice-states/@me
    func editCurrentUserVoiceState<B: Encodable>(
        _ guildId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/voice-states/@me/",
            body: body
        )
    }
    // MARK: Edit User Voice State
    // PATCH /guilds/${GuildId}/voice-states/${UserId}
    func editUserVoiceState<B: Encodable>(
        _ guildId: Snowflake,
        _ userId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "guilds/\(guildId)/voice-states/\(userId)/",
            body: body
        )
    }
}
