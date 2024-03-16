//
//  GuildMember.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

public struct GuildMemberRemove: Codable, GatewayData {
    public let guild_id: Snowflake
    public let user: User
}

/// Sent when a guild member is updated.
/// This will also fire when the user object of a guild member changes.
/// Very similar to Member, but with some optional value changes
public struct GuildMemberUpdate: Codable, GatewayData {
    public let guild_id: Snowflake
    public let roles: [Snowflake] // User role IDs
    public let user: User
    public let nick: String?
    public let avatar: String? // User's guild avatar hash
    public let joined_at: Date?
    public let premium_since: Date? // When user started boosting guild
    public let deaf: Bool?
    public let mute: Bool?
    public let pending: Bool?
    public let communication_disabled_until: Date?
}

public struct GuildMemberListUpdate: Decodable, GatewayData {
    public struct Group: Decodable, Identifiable, GatewayData {
        public let id: Snowflake
        public let count: Int
    }

    public struct Data: Codable {
        public struct Group: Codable {
            public let id: Snowflake
        }

        public let member: Member?
        public let group: Group?
    }

    public enum UpdateOp: Decodable, GatewayData {
        private enum Op: String, Codable {
            case update = "UPDATE"
            case sync = "SYNC"
            case delete = "DELETE"
            case insert = "INSERT"
            case invalidate = "INVALIDATE"
        }

        case update(Data, index: Int)
        case insert(Data, index: Int)
        case delete(Int)
        case sync([Data], range: DiscordRange)
        case invalidate(DiscordRange)

        enum CodingKeys: CodingKey {
            case index
            case range
            case item
            case items
            case op
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let op = try container.decode(Op.self, forKey: .op)
            switch op {
            case .sync:
                self = .sync(try container.decode([Data].self, forKey: .items), range: try container.decode(DiscordRange.self, forKey: .range))
            case .update:
                self = .update(try container.decode(Data.self, forKey: .item), index: try container.decode(Int.self, forKey: .index))
            case .insert:
                self = .insert(try container.decode(Data.self, forKey: .item), index: try container.decode(Int.self, forKey: .index))
            case .delete:
                self = .delete(try container.decode(Int.self, forKey: .index))
            case .invalidate:
                self = .invalidate(try container.decode(DiscordRange.self, forKey: .range))
            }
        }
    }

    public let groups: [Group]
    public let guild_id: Snowflake
    public let id: String
    public let member_count: Int
    public let online_count: Int
    public let ops: [UpdateOp]
}
