//
//  Identify.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

public extension RobustWebSocket {
    /// Returns a `GatewayIdentify` struct for identification
    /// during Gateway connection
    ///
    /// Populates the `GatewayIdentify` struct from the socket's token
    /// and current DiscordKit configuration. This method should not normally
    /// need to be called from outside `RobustWebSocket`.
    internal func getIdentify() -> GatewayIdentify {
        GatewayIdentify(
            token: token,
            properties: DiscordKitConfig.default.properties.addingGatewayIdentifyFields(
                clientAppState: "focused",
                isFastConnect: false,
                gatewayConnectReasons: "",
                installationID: nil
            ),
            compress: false,
            large_threshold: nil,
            shard: nil,
            presence: GatewayPresenceUpdate(since: 0, activities: [], status: .online, afk: false),
            client_state: DiscordKitConfig.default.isBot ? nil : ClientState(),
            capabilities: DiscordKitConfig.default.isBot ? nil : 1_734_653,
            intents: DiscordKitConfig.default.isBot ? DiscordKitConfig.default.intents : nil
        )
    }

    /// Returns a GatewayResume struct based on the provided session ID and sequence
    ///
    /// This method is similar to the `getIdentify()` method, but
    /// returns a `GatewayResume` struct instead, which is used when
    /// attempting to resume. This method should not normally need
    /// to be called from outside `RobustWebSocket`.
    internal func getResume(seq: Int?, sessionID: String) -> GatewayResume {
        GatewayResume(
            token: token,
            session_id: sessionID,
            seq: seq
        )
    }
}
