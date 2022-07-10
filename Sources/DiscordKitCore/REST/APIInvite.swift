//
//  File.swift
//  
//
//  Created by Vincent Kwok on 10/7/22.
//

import Foundation

public extension DiscordREST {
    /// Get Current User Guild Member
    ///
    /// `GET /invites/{inviteID}`
    ///
    ///https://canary.discord.com/api/v9/invites/dosjopkqwef?inputValue=dosjopkqwef&with_counts=true&with_expiration=true
    /// Get guild member object for current user in a guild
    func resolveInvite(
        inviteID: String,
        inputValue: String,
        withCounts: Bool = true,
        withExpiration: Bool = true
    ) async -> Invite? {
        return await getReq(path: "invites/\(inviteID)", query: [
            URLQueryItem(name: "with_counts", value: String(withCounts)),
            URLQueryItem(name: "with_expiration", value: String(withExpiration))
        ])
    }
}
