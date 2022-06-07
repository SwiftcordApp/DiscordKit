//
//  APIUser.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 22/2/22.
//

import Foundation
import DiscordKitCommon

public extension DiscordREST {
    // MARK: Get Current User
    // GET /users/@me
    func getCurrentUser() async -> User? {
        return await getReq(path: "users/@me")
    }

    // MARK: Get User (Get user object from ID)
    // GET /users/{user.id}
    func getUser(user: Snowflake) async -> User? {
        return await getReq(path: "users/\(user)")
    }

    // MARK: Get Profile (Undocumented endpoint!)
    // GET /users/{user.id}
    func getProfile(
        user: Snowflake,
        mutualGuilds: Bool = false,
        guildID: Snowflake? = nil
    ) async -> UserProfile? {
        var query = [URLQueryItem(name: "with_mutual_guilds", value: String(mutualGuilds))]
        if let guildID = guildID {
            query.append(URLQueryItem(name: "guild_id", value: guildID))
        }
        return await getReq(path: "users/\(user)/profile", query: query)
    }

    // MARK: Modify Current User
    // TODO: Patch not yet implemented

    // MARK: Get Current User Guilds
    // GET /users/@me/guilds
    func getGuilds(
        before: Snowflake? = nil,
        after: Snowflake? = nil,
        limit: Int = 200
    ) async -> [PartialGuild]? {
        return await getReq(path: "users/@me/guilds")
    }

    // MARK: Get Current User Guild Member
    // Get guild member object for current user in a guild
    // GET /users/@me/guilds/{guild.id}/member
    func getGuildMember(guild: Snowflake) async -> Member? {
        return await getReq(path: "users/@me/guilds/\(guild)/member")
    }

    // MARK: Leave Guild
    // DELETE /users/@me/guilds/{guild.id}
    // TODO: Delete not yet implemented

    // MARK: Create DM

}
