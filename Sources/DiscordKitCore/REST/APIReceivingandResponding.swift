// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    /// Create Interaction Response
    ///
    /// > POST: `/interactions/{interaction.id}/{interaction.token}/callback`
    func createInteractionResponse<T: Decodable, B: Encodable>(
        _ interactionId: Snowflake,
        _ interactionToken: String,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "interactions/\(interactionId)/\(interactionToken)/callback",
            body: body
        )
    }
    /// Get Original Interaction Response
    ///
    /// > GET: `/webhooks/{application.id}/{interaction.token}/messages/@original`
    func getOriginalInteractionResponse<T: Decodable>(
        _ applicationId: Snowflake,
        _ interactionToken: String
    ) async throws -> T {
        return try await getReq(
            path: "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
        )
    }
    /// Edit Original Interaction Response
    ///
    /// > PATCH: `/webhooks/{application.id}/{interaction.token}/messages/@original`
    func editOriginalInteractionResponse<B: Encodable>(
        _ applicationId: Snowflake,
        _ interactionToken: String,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "webhooks/\(applicationId)/\(interactionToken)/messages/@original",
            body: body
        )
    }
    /// Delete Original Interaction Response
    ///
    /// > DELETE: `/webhooks/{application.id}/{interaction.token}/messages/@original`
    func deleteOriginalInteractionResponse(
        _ applicationId: Snowflake,
        _ interactionToken: String
    ) async throws {
        try await deleteReq(
            path: "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
        )
    }
    /// Create Followup Message
    ///
    /// > POST: `/webhooks/{application.id}/{interaction.token}`
    func createFollowupMessage<T: Decodable, B: Encodable>(
        _ applicationId: Snowflake,
        _ interactionToken: String,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "webhooks/\(applicationId)/\(interactionToken)",
            body: body
        )
    }
    /// Get Followup Message
    ///
    /// > GET: `/webhooks/{application.id}/{interaction.token}/messages/{message.id}`
    func getFollowupMessage<T: Decodable>(
        _ applicationId: Snowflake,
        _ interactionToken: String,
        _ messageId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
        )
    }
    /// Edit Followup Message
    ///
    /// > PATCH: `/webhooks/{application.id}/{interaction.token}/messages/{message.id}`
    func editFollowupMessage<B: Encodable>(
        _ applicationId: Snowflake,
        _ interactionToken: String,
        _ messageId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)",
            body: body
        )
    }
    /// Delete Followup Message
    ///
    /// > DELETE: `/webhooks/{application.id}/{interaction.token}/messages/{message.id}`
    func deleteFollowupMessage(
        _ applicationId: Snowflake,
        _ interactionToken: String,
        _ messageId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
        )
    }
}
