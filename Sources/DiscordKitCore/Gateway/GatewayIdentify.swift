//
//  Identify.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation
import DiscordKitCommon

public extension RobustWebSocket {
    /// Returns a `GatewayIdentify` struct for identification
    /// during Gateway connection
    ///
    /// Retrives the Discord token from the keychain and populates
    /// the `GatewayIdentify` struct. This method should not normally
    /// need to be called from outside `RobustWebSocket`.
    ///
    /// - Returns: A `GatewayIdentify` struct, or nil if the Discord token is
    /// not present in the keychain
    internal func getIdentify() -> GatewayIdentify? {
        // Keychain.save(key: "token", data: "token goes here")
        // Keychain.remove(key: "token") // For testing
        return GatewayIdentify(
            token: self.token,
			properties: DiscordREST.getSuperProperties(),
            compress: false,
            large_threshold: nil,
            shard: nil,
            presence: nil,
            capabilities: 0b11111101 // TODO: Reverse engineer this
        )
    }

    /// Returns a GatewayResume struct based on the provided session ID and sequence
    ///
    /// This method is similar to the `getIdentify()` method, but
    /// returns a `GatewayResume` struct instead, which is used when
    /// attempting to resume. This method should not normally need
    /// to be called from outside `RobustWebSocket`.
    ///
    /// - Returns: A `GatewayResume` struct, or nil if the Discord token is
    /// not present in the keychain
    internal func getResume(seq: Int, sessionID: String) -> GatewayResume? {
        return GatewayResume(
            token: token,
            session_id: sessionID,
            seq: seq
        )
    }
}
