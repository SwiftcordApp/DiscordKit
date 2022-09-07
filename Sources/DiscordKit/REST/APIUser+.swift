//
//  APIUser+.swift
//  
//
//  Created by Vincent Kwok on 7/9/22.
//

import Foundation
import DiscordKitCore
import DiscordKitCommon

public extension DiscordREST {
    /// Update user settings proto
    ///
    /// `PATCH /users/@me/settings-proto/{id}`
    @discardableResult
    func updateSettingsProto(
        proto: Data,
        type: Int = 1 // Always 1 for now
    ) async -> Bool {
        return await patchReq(
            path: "users/@me/settings-proto/\(type)",
            body: UserSettingsProtoUpdate(settings: proto.base64EncodedString())
        )
    }
}
