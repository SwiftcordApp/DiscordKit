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
    /// Retrives the Discord token from the keychain and populates
    /// the `GatewayIdentify` struct. This method should not normally
    /// need to be called from outside `RobustWebSocket`.
    ///
    /// - Returns: A `GatewayIdentify` struct, or nil if the Discord token is
    /// not present in the keychain
    internal func getIdentify() -> GatewayIdentify? {
        return GatewayIdentify(
            token: token,
            properties: DiscordKitConfig.default.properties,
            compress: false,
            large_threshold: nil,
            shard: nil,
            presence: GatewayPresenceUpdate(since: 0, activities: [], status: .online, afk: false),
            client_state: DiscordKitConfig.default.isBot ? nil : ClientState( // Just a dummy client_state
                api_code_version: 0,
                guild_versions: .init(),
                highest_last_message_id: "0",
                initial_guild_id: nil,
                private_channels_version: "0",
                read_state_version: 0,
                user_guild_settings_version: -1,
                user_settings_version: -1
            ),
            capabilities: DiscordKitConfig.default.isBot ? nil : 8189, // TODO: Reverse engineer this
            intents: DiscordKitConfig.default.isBot ? DiscordKitConfig.default.intents : nil
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
    internal func getResume(seq: Int?, sessionID: String) -> GatewayResume? {
        return GatewayResume(
            token: token,
            session_id: sessionID,
            seq: seq
        )
    }
}
