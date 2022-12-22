// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    // MARK: Create Lobby
    // POST /lobbies
    func createLobby<T: Decodable, B: Encodable>(_ body: B) async throws -> T {
        return try await postReq(
            path: "lobbies/",
            body: body
        )
    }
    // MARK: Update Lobby
    // PATCH /lobbies/${LobbyId}
    func updateLobby<B: Encodable>(
        _ lobbyId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "lobbies/\(lobbyId)/",
            body: body
        )
    }
    // MARK: Delete Lobby
    // DELETE /lobbies/${LobbyId}
    func deleteLobby(
        _ lobbyId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "lobbies/\(lobbyId)/"
        )
    }
    // MARK: Update Lobby Member
    // PATCH /lobbies/${LobbyId}/members/${UserId}
    func updateLobbyMember<B: Encodable>(
        _ lobbyId: Snowflake,
        _ userId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "lobbies/\(lobbyId)/members/\(userId)/",
            body: body
        )
    }
    // MARK: Create Lobby Search
    // POST /lobbies/search
    func createLobbySearch<T: Decodable, B: Encodable>(_ body: B) async throws -> T {
        return try await postReq(
            path: "lobbies/search/",
            body: body
        )
    }
    // MARK: Send Lobby Data
    // POST /lobbies/${LobbyId}/send
    func sendLobbyData<T: Decodable, B: Encodable>(
        _ lobbyId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "lobbies/\(lobbyId)/send/",
            body: body
        )
    }
}
