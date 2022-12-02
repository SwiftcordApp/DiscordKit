//
//  APIGuild.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 22/2/22.
//

import Foundation

public extension DiscordREST {
    // MARK: Get Guild
    // GET /guilds/{guild.id}
    func getGuild(id: Snowflake) async -> Result<Guild, RequestError> {
        return await getReq(path: "guilds/\(id)")
    }

    // MARK: Get Guild Channels
    // GET /guilds/{guild.id}/channels
    func getGuildChannels(id: Snowflake) async -> Result<[DecodableThrowable<Channel>], RequestError> {
        return await getReq(path: "guilds/\(id)/channels")
    }

    // MARK: Get Guild Roles
    // GET /guilds/{guild.id}/roles
    func getGuildRoles(id: Snowflake) async -> Result<[Role], RequestError> {
        return await getReq(path: "guilds/\(id)/roles")
    }
}
