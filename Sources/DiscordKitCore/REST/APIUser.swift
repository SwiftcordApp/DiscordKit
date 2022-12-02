//
//  APIUser.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 22/2/22.
//

import Foundation

public extension DiscordREST {
    /// Get Current User
    ///
    /// `GET /users/@me`
    func getCurrentUser() async -> Result<User, RequestError> {
        return await getReq(path: "users/@me")
    }

    /// Get User
    ///
    /// `GET /users/{user.id}`
    ///
    /// - Parameter user: ID of user to retrieve
    func getUser(user: Snowflake) async -> Result<User, RequestError> {
        return await getReq(path: "users/\(user)")
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
    ) async -> Result<UserProfile, RequestError> {
        var query = [URLQueryItem(name: "with_mutual_guilds", value: String(mutualGuilds))]
        if let guildID = guildID {
            query.append(URLQueryItem(name: "guild_id", value: guildID))
        }
        return await getReq(path: "users/\(user)/profile", query: query)
    }

    // MARK: Modify Current User
    // TODO: Patch not yet implemented

    /// Get Current User Guilds
    ///
    /// `GET /users/@me/guilds`
    func getGuilds(
        before: Snowflake? = nil,
        after: Snowflake? = nil,
        limit: Int = 200
    ) async -> Result<[PartialGuild], RequestError> {
        return await getReq(path: "users/@me/guilds")
    }

    /// Get Current User Guild Member
    ///
    /// `GET /users/@me/guilds/{guild.id}/member`
    ///
    /// Get guild member object for current user in a guild
    func getGuildMember(guild: Snowflake) async -> Result<Member, RequestError> {
        return await getReq(path: "users/@me/guilds/\(guild)/member")
    }

    // MARK: Leave Guild
    // DELETE /users/@me/guilds/{guild.id}
    func leaveGuild(guild: Snowflake) async throws {
        return try await deleteReq(path: guild)
    }

    // MARK: Create DM

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
}
