// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    /// Get Current User
    ///
    /// `GET /users/@me`
    func getCurrentUser() async throws -> User {
        return try await getReq(path: "users/@me")
    }

    /// Get User
    ///
    /// `GET /users/{user.id}`
    ///
    /// - Parameter user: ID of user to retrieve
    func getUser(user: Snowflake) async throws -> User {
        return try await getReq(path: "users/\(user)")
    }

    /// Get Profile
    ///
    /// `GET /users/{user.id}`
    /// > Warning:  This is an undocumented endpoint
    ///
    /// - Parameters:
    ///   - user: ID of user to retrieve profile
    ///   - mutualGuilds: If the user's mutual guilds with the current user should be returned as well
    ///   - guildID: The ID of the guild the action that triggered profile retrival was carried out in. Pass `nil`
    ///   if the action was carried out in a DM channel.
    func getProfile(
        user: Snowflake,
        mutualGuilds: Bool = false,
        guildID: Snowflake? = nil
    ) async throws -> UserProfile {
        var query = [URLQueryItem(name: "with_mutual_guilds", value: String(mutualGuilds))]
        if let guildID = guildID {
            query.append(URLQueryItem(name: "guild_id", value: guildID))
        }
        return try await getReq(path: "users/\(user)/profile", query: query)
    }

    /// Modify Current User
    ///
    /// TODO: Patch not yet implemented

    /// Get Current User Guilds
    ///
    /// `GET /users/@me/guilds`
    func getGuilds(
        before: Snowflake? = nil,
        after: Snowflake? = nil,
        limit: Int = 200
    ) async throws -> [PartialGuild] {
        return try await getReq(path: "users/@me/guilds")
    }

    /// Get Current User Guild Member
    ///
    /// `GET /users/@me/guilds/{guild.id}/member`
    ///
    /// Get guild member object for current user in a guild
    func getGuildMember(guild: Snowflake) async throws -> Member {
        return try await getReq(path: "users/@me/guilds/\(guild)/member")
    }

    /// Leave Guild
    ///
    /// > DELETE: `/users/@me/guilds/{guild.id}`
    func leaveGuild(guild: Snowflake) async throws {
        return try await deleteReq(path: guild)
    }

    /// Log out
    ///
    /// `POST /auth/logout`
    /// > Warning:  This is an undocumented endpoint
    ///
    /// - Parameters:
    ///   - provider: Unknown, always observed to be nil
    ///   - voipProvider: Unknown, always observed to be nil
    func logOut(provider: String? = nil, voipProvider: String? = nil) async throws {
        return try await postReq(path: "auth/logout", body: LogOut(provider: provider, voip_provider: voipProvider))
    }
    /// Edit Current User
    ///
    /// > PATCH: `/users/@me`
    func editCurrentUser<B: Encodable>(_ body: B) async throws {
        try await patchReq(
            path: "users/@me",
            body: body
        )
    }
    /// Create DM
    ///
    /// > POST: `/users/@me/channels`
    func createDM<T: Decodable, B: Encodable>(_ body: B) async throws -> T {
        return try await postReq(
            path: "users/@me/channels",
            body: body
        )
    }
    /// Create Group DM
    ///
    /// > POST: `/users/@me/channels`
    func createGroupDM<T: Decodable, B: Encodable>(_ body: B) async throws -> T {
        return try await postReq(
            path: "users/@me/channels",
            body: body
        )
    }
    /// Get User Connections
    ///
    /// > GET: `/users/@me/connections`
    func getUserConnections<T: Decodable>() async throws -> T {
        return try await getReq(
            path: "users/@me/connections"
        )
    }
    /// Get User Application Role Connection
    ///
    /// > GET: `/users/@me/applications/{application.id}/role-connection`
    func getUserApplicationRoleConnection<T: Decodable>(
        _ applicationId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "users/@me/applications/\(applicationId)/role-connection"
        )
    }
    /// Update User Application Role Connection
    ///
    /// > PUT: `/users/@me/applications/{application.id}/role-connection`
    func updateUserApplicationRoleConnection<T: Decodable, B: Encodable>(
        _ applicationId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "users/@me/applications/\(applicationId)/role-connection",
            body: body
        )
    }
}
