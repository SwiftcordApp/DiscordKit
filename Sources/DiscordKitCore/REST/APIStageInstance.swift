// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    /// Create Stage Instance
    ///
    /// > POST: `/stage-instances`
    func createStageInstance<T: Decodable, B: Encodable>(_ body: B) async throws -> T {
        return try await postReq(
            path: "stage-instances",
            body: body
        )
    }
    /// Get Stage Instance
    ///
    /// > GET: `/stage-instances/{channel.id}`
    func getStageInstance<T: Decodable>(
        _ channelId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "stage-instances/\(channelId)"
        )
    }
    /// Edit Stage Instance
    ///
    /// > PATCH: `/stage-instances/{channel.id}`
    func editStageInstance<B: Encodable>(
        _ channelId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "stage-instances/\(channelId)",
            body: body
        )
    }
    /// Delete Stage Instance
    ///
    /// > DELETE: `/stage-instances/{channel.id}`
    func deleteStageInstance(
        _ channelId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "stage-instances/\(channelId)"
        )
    }
}
