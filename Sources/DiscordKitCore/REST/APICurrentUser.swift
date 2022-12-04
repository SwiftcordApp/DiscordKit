//
//  APICurrentUser.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 7/3/22.
//

import Foundation

/// API endpoints for everything related to the current user only
/// Most (all) endpoints here aren't documented and were found
/// from reverse engineering, observation and speculation.
public extension DiscordREST {
    // MARK: Get Current User DMs
    // GET /users/@me/channels
    func getDMs() async throws -> [DecodableThrowable<Channel>] {
        return try await getReq(path: "users/@me/channels")
    }

    // MARK: Change Current User Password
    // PATCH /users/@me
    // Fields: new_password, password
    // Returns: User
    func changeCurUserPW(
        oldPW: String,
        newPW: String
    ) async -> User? {
        // Patch isn't implemented yet

        return nil
    }
}
