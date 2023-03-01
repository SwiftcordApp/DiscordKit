// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    /// Create Lobby
    ///
    /// > POST: `/lobbies`
    func createLobby<T: Decodable, B: Encodable>(_ body: B) async throws -> T {
        return try await postReq(
            path: "lobbies",
            body: body
        )
    }
    /// Update Lobby
    ///
    /// > PATCH: `/lobbies/{lobby.id}`
    func updateLobby<B: Encodable>(
        _ lobbyId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "lobbies/\(lobbyId)",
            body: body
        )
    }
    /// Delete Lobby
    ///
    /// > DELETE: `/lobbies/{lobby.id}`
    func deleteLobby(
        _ lobbyId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "lobbies/\(lobbyId)"
        )
    }
    /// Update Lobby Member
    ///
    /// > PATCH: `/lobbies/{lobby.id}/members/{user.id}`
    func updateLobbyMember<B: Encodable>(
        _ lobbyId: Snowflake,
        _ userId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "lobbies/\(lobbyId)/members/\(userId)",
            body: body
        )
    }
    /// Create Lobby Search
    ///
    /// > POST: `/lobbies/search`
    func createLobbySearch<T: Decodable, B: Encodable>(_ body: B) async throws -> T {
        return try await postReq(
            path: "lobbies/search",
            body: body
        )
    }
    /// Send Lobby Data
    ///
    /// > POST: `/lobbies/{lobby.id}/send`
    func sendLobbyData<T: Decodable, B: Encodable>(
        _ lobbyId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "lobbies/\(lobbyId)/send",
            body: body
        )
    }
}
