//
//  APICommand.swift
//  
//
//  Created by Vincent Kwok on 26/11/22.
//

import Foundation
import DiscordKitCore

public extension DiscordREST {
    /// Create global application command
    ///
    /// > POST: `/applications/{application.id}/commands`
    /// This creates a global application command available in all guilds.
    func createGlobalCommand(_ command: NewAppCommand, applicationID: Snowflake) async throws {
        try await postReq(path: "applications/\(applicationID)/commands", body: command)
    }

    /// Create guild application command
    ///
    /// > POST: `/applications/{application.id}/guilds/{guild.id}/commands`
    ///
    /// This creates a global application command scoped to a specific guild.
    ///
    /// > Tip: This is useful for testing as guild commands update immediately,
    /// > while updates to global commands take some time to propagate.
    func createGuildCommand(_ command: NewAppCommand, applicationID: Snowflake, guildID: Snowflake) async throws {
        try await postReq(path: "applications/\(applicationID)/guilds/\(guildID)/commands", body: command)
    }

    /// Utility method to conditionally create a guild or global command depending on parameters
    func createCommand(_ command: NewAppCommand, applicationID: Snowflake, guildID: Snowflake?) async throws {
        if let guildID = guildID {
            try await createGuildCommand(command, applicationID: applicationID, guildID: guildID)
        } else {
            try await createGlobalCommand(command, applicationID: applicationID)
        }
    }

    /// Send a response to an interaction
    func sendInteractionResponse(_ response: InteractionResponse, interactionID: Snowflake, token: String) async throws {
        let b = try DiscordREST.encoder.encode(response)
        try await postReq(path: "interactions/\(interactionID)/\(token)/callback", body: response)
    }
}
