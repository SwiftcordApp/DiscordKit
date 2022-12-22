// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    // MARK: Create Stage Instance
    // POST /stage-instances
    func createStageInstance<T: Decodable, B: Encodable>(_ body: B) async throws -> T {
        return try await postReq(
            path: "stage-instances/",
            body: body
        )
    }
    // MARK: Get Stage Instance
    // GET /stage-instances/${ChannelId}
    func getStageInstance<T: Decodable>(
        _ channelId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "stage-instances/\(channelId)/"
        )
    }
    // MARK: Edit Stage Instance
    // PATCH /stage-instances/${ChannelId}
    func editStageInstance<B: Encodable>(
        _ channelId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "stage-instances/\(channelId)/",
            body: body
        )
    }
    // MARK: Delete Stage Instance
    // DELETE /stage-instances/${ChannelId}
    func deleteStageInstance(
        _ channelId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "stage-instances/\(channelId)/"
        )
    }
}
