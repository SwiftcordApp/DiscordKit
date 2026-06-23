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
    public let merged_members: [[Member]]?
    @DefaultInitialDecodable public var merged_presences: MergedPresences
    public let lazy_private_channels: [DecodeThrowable<Channel>]?
}

public struct ReadySupplementalGuild: Decodable, GatewayData {
    public let id: Snowflake
    public let voice_states: [VoiceState]?
    public let unavailable: Bool?
}

public struct MergedPresences: GatewayData, DefaultInitializable {
    @DefaultEmptyArrayDecodable public var guilds: [[Presence]]
    @DefaultEmptyArrayDecodable public var friends: [Presence]

    public init() {
        self.init(guilds: [], friends: [])
    }

    public init(guilds: [[Presence]] = [], friends: [Presence] = []) {
        _guilds = DefaultEmptyArrayDecodable(wrappedValue: guilds)
        _friends = DefaultEmptyArrayDecodable(wrappedValue: friends)
    }
}
