// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    /// Get Current User Guild Member
    ///
    /// `GET /invites/{inviteID}`
    ///
    /// Get guild member object for current user in a guild
    ///
    /// > Example URL:
    /// >
    /// > `https://canary.discord.com/api/v9/invites/dosjopkqwef?inputValue=dosjopkqwef&with_counts=true&with_expiration=true`
    func resolveInvite(
        inviteID: String,
        inputValue: String,
        withCounts: Bool = true,
        withExpiration: Bool = true
    ) async throws -> Invite {
        return try await getReq(path: "invites/\(inviteID)", query: [
            URLQueryItem(name: "with_counts", value: String(withCounts)),
            URLQueryItem(name: "with_expiration", value: String(withExpiration))
        ])
    }
    /// Get Invite
    ///
    /// > GET: `/invites/{invite.code}`
    func getInvite<T: Decodable>(
        _ inviteCode: String
    ) async throws -> T {
        return try await getReq(
            path: "invites/\(inviteCode)"
        )
    }
    /// Delete Invite
    ///
    /// > DELETE: `/invites/{invite.code}`
    func deleteInvite(
        _ inviteCode: String
    ) async throws {
        try await deleteReq(
            path: "invites/\(inviteCode)"
        )
    }
}
