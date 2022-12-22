// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    // MARK: Get Current Bot Application Information
    // GET /oauth2/applications/@me
    func getCurrentBotApplicationInformation<T: Decodable>() async throws -> T {
        return try await getReq(
            path: "oauth2/applications/@me/"
        )
    }
    // MARK: Get Current Authorization Information
    // GET /oauth2/@me
    func getCurrentAuthorizationInformation<T: Decodable>() async throws -> T {
        return try await getReq(
            path: "oauth2/@me/"
        )
    }
}
