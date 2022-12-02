//
//  APIUser+.swift
//  
//
//  Created by Vincent Kwok on 7/9/22.
//

import Foundation
import DiscordKitCore

public extension DiscordREST {
    /// Update user settings proto
    ///
    /// `PATCH /users/@me/settings-proto/{id}`
    func updateSettingsProto(
        proto: Data,
        type: Int = 1 // Always 1 for now
    ) async throws {
        return try await patchReq(
            path: "users/@me/settings-proto/\(type)",
            body: UserSettingsProtoUpdate(settings: proto.base64EncodedString())
        )
    }
}
