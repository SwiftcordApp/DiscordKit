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
    func createGlobalCommand(_ command: NewAppCommand, applicationID: Snowflake) async throws -> AppCommand {
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
    func createGuildCommand(
        _ command: NewAppCommand,
        applicationID: Snowflake, guildID: Snowflake
    ) async throws -> AppCommand {
        try await postReq(path: "applications/\(applicationID)/guilds/\(guildID)/commands", body: command)
    }

    /// Utility method to conditionally create a guild or global command depending on parameters
    func createCommand(
        _ command: NewAppCommand,
        applicationID: Snowflake, guildID: Snowflake?
    ) async throws -> AppCommand {
        if let guildID = guildID {
            return try await createGuildCommand(command, applicationID: applicationID, guildID: guildID)
        } else {
            return try await createGlobalCommand(command, applicationID: applicationID)
        }
    }

    /// Builk overwrite global application command
    ///
    /// > PUT: `/applications/{application.id}/commands`
    ///
    /// Overwrite global application commands with those provided.
    ///
    /// > Warning:
    /// > This will overwrite **all** types of application commands: slash commands, user
    /// > commands, and message commands.
    func bulkOverwriteGlobalCommands(
        _ commands: [NewAppCommand], applicationID: Snowflake
    ) async throws -> [AppCommand] {
        try await putReq(path: "applications/\(applicationID)/commands", body: commands)
    }

    /// Builk overwrite guild application command
    ///
    /// > PUT: `/applications/{application.id}/guilds/{guild.id}/commands`
    ///
    /// Overwrite the application commands scoped to a certain guild with those provided.
    ///
    /// > Warning:
    /// > This will overwrite **all** types of application commands: slash commands, user
    /// > commands, and message commands.
    ///
    /// > Tip: This is useful for testing as guild commands update immediately,
    /// > while updates to global commands take some time to propagate.
    func bulkOverwriteGuildCommands(
        _ commands: [NewAppCommand],
        applicationID: Snowflake,
        guildID: Snowflake
    ) async throws -> [AppCommand] {
        try await putReq(path: "applications/\(applicationID)/guilds/\(guildID)/commands", body: commands)
    }

    /// Utility method to conditionally bulk overwrite guild or global commands depending on parameters
    func bulkOverwriteCommands(
        _ commands: [NewAppCommand],
        applicationID: Snowflake, guildID: Snowflake?
    ) async throws -> [AppCommand] {
        if let guildID = guildID {
            return try await bulkOverwriteGuildCommands(commands, applicationID: applicationID, guildID: guildID)
        } else {
            return try await bulkOverwriteGlobalCommands(commands, applicationID: applicationID)
        }
    }

    /// Send a response to an interaction
    func sendInteractionResponse(_ response: InteractionResponse, interactionID: Snowflake, token: String) async throws {
        try await postReq(path: "interactions/\(interactionID)/\(token)/callback", body: response)
    }

    /// Send a follow up response to an interaction
    ///
    /// > POST: `/webhooks/{application.id}/{interaction.token}`
    func sendInteractionFollowUp(_ response: WebhookResponse, applicationID: Snowflake, token: String) async throws -> Message {
        try await postReq(path: "webhooks/\(applicationID)/\(token)", body: response)
    }
}
