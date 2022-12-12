//
//  APICommand.swift
//  
//
//  Created by Vincent Kwok on 26/11/22.
//

import Foundation

public extension DiscordREST {
    /// Create global application command
    ///
    /// > POST: `/applications/{application.id}/commands`
    /// This creates a global application command available in all guilds.
    func createGlobalCommand(_ command: CreateAppCmd, applicationID: Snowflake) async throws {
        return try await postReq(path: "applications/\(applicationID)/commands", body: command)
    }

    /// Create guild application command
    ///
    /// > POST: `/applications/{application.id}/guilds/{guild.id}/commands`
    ///
    /// This creates a global application command scoped to a specific guild.
    ///
    /// > Tip: This is useful for testing as guild commands update immediately,
    /// > while updates to global commands take some time to propagate.
    func createGuildCommand(_ command: CreateAppCmd, applicationID: Snowflake, guildID: Snowflake) async throws {
        return try await postReq(path: "applications/\(applicationID)/guilds/\(guildID)/commands", body: command)
    }
}
