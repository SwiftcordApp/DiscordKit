// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    // MARK: Create Interaction Response
    // POST /interactions/${InteractionId}/${InteractionToken}/callback
    func createInteractionResponse<T: Decodable, B: Encodable>(
        _ interactionId: Snowflake,
        _ interactionToken: String,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "interactions/\(interactionId)/\(interactionToken)/callback/",
            body: body
        )
    }
    // MARK: Get Original Interaction Response
    // GET /webhooks/${ApplicationId}/${InteractionToken}/messages/@original
    func getOriginalInteractionResponse<T: Decodable>(
        _ applicationId: Snowflake,
        _ interactionToken: String
    ) async throws -> T {
        return try await getReq(
            path: "webhooks/\(applicationId)/\(interactionToken)/messages/@original/"
        )
    }
    // MARK: Edit Original Interaction Response
    // PATCH /webhooks/${ApplicationId}/${InteractionToken}/messages/@original
    func editOriginalInteractionResponse<B: Encodable>(
        _ applicationId: Snowflake,
        _ interactionToken: String,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "webhooks/\(applicationId)/\(interactionToken)/messages/@original/",
            body: body
        )
    }
    // MARK: Delete Original Interaction Response
    // DELETE /webhooks/${ApplicationId}/${InteractionToken}/messages/@original
    func deleteOriginalInteractionResponse(
        _ applicationId: Snowflake,
        _ interactionToken: String
    ) async throws {
        try await deleteReq(
            path: "webhooks/\(applicationId)/\(interactionToken)/messages/@original/"
        )
    }
    // MARK: Create Followup Message
    // POST /webhooks/${ApplicationId}/${InteractionToken}
    func createFollowupMessage<T: Decodable, B: Encodable>(
        _ applicationId: Snowflake,
        _ interactionToken: String,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "webhooks/\(applicationId)/\(interactionToken)/",
            body: body
        )
    }
    // MARK: Get Followup Message
    // GET /webhooks/${ApplicationId}/${InteractionToken}/messages/${MessageId}
    func getFollowupMessage<T: Decodable>(
        _ applicationId: Snowflake,
        _ interactionToken: String,
        _ messageId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)/"
        )
    }
    // MARK: Edit Followup Message
    // PATCH /webhooks/${ApplicationId}/${InteractionToken}/messages/${MessageId}
    func editFollowupMessage<B: Encodable>(
        _ applicationId: Snowflake,
        _ interactionToken: String,
        _ messageId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)/",
            body: body
        )
    }
    // MARK: Delete Followup Message
    // DELETE /webhooks/${ApplicationId}/${InteractionToken}/messages/${MessageId}
    func deleteFollowupMessage(
        _ applicationId: Snowflake,
        _ interactionToken: String,
        _ messageId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)/"
        )
    }
}
