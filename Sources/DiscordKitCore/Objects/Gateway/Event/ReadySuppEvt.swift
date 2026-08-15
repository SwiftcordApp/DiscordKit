//
//  File.swift
//  
//
//  Created by Vincent Kwok on 5/9/22.
//

import Foundation

/// Payload sent with ``GatewayEvent/readySupplemental``
public struct ReadySuppEvt: Decodable, GatewayData {
    public let guilds: [ReadySupplementalGuild]?
    @LossyNestedArrayDecodable public var merged_members: [[Member]]
    @DefaultInitialDecodable public var merged_presences: MergedPresences
    public let lazy_private_channels: [DecodeThrowable<Channel>]?
}

public struct ReadySupplementalGuild: Decodable, GatewayData {
    public let id: Snowflake
    public let voice_states: [VoiceState]?
    public let unavailable: Bool?
}

public struct MergedPresences: GatewayData, DefaultInitializable {
    @LossyNestedArrayDecodable public var guilds: [[Presence]]
    @LossyArrayDecodable public var friends: [Presence]

    public init() {
        self.init(guilds: [], friends: [])
    }

    public init(guilds: [[Presence]] = [], friends: [Presence] = []) {
        _guilds = LossyNestedArrayDecodable(wrappedValue: guilds)
        _friends = LossyArrayDecodable(wrappedValue: friends)
    }
}
