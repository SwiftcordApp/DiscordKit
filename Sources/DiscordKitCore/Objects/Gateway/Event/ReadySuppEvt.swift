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
    public let merged_presences: MergedPresences
    public let lazy_private_channels: [DecodeThrowable<Channel>]?

    private enum CodingKeys: String, CodingKey {
        case guilds
        case merged_members
        case merged_presences
        case lazy_private_channels
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guilds = try container.decodeIfPresent([ReadySupplementalGuild].self, forKey: .guilds)
        merged_members = try container.decodeIfPresent([[Member]].self, forKey: .merged_members)
        merged_presences = try container.decodeIfPresent(MergedPresences.self, forKey: .merged_presences) ?? .init()
        lazy_private_channels = try container.decodeIfPresent([DecodeThrowable<Channel>].self, forKey: .lazy_private_channels)
    }
}

public struct ReadySupplementalGuild: Decodable, GatewayData {
    public let id: Snowflake
    public let voice_states: [VoiceState]?
    public let unavailable: Bool?
}

public struct MergedPresences: GatewayData {
    public let guilds: [[Presence]]
    public let friends: [Presence]

    public init(guilds: [[Presence]] = [], friends: [Presence] = []) {
        self.guilds = guilds
        self.friends = friends
    }

    private enum CodingKeys: String, CodingKey {
        case guilds
        case friends
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guilds = try container.decodeIfPresent([[Presence]].self, forKey: .guilds) ?? []
        friends = try container.decodeIfPresent([Presence].self, forKey: .friends) ?? []
    }
}
