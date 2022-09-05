//
//  Presence.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

/// User presences sent in the ``GatewayEvent/readySupplemental`` event
public struct Presence: GatewayData {
    public let user_id: Snowflake
    public let status: PresenceStatus
    public let client_status: PresenceClientStatus
    public let activities: [Activity]
}

public enum PresenceStatus: String, Codable {
    case idle = "idle"
    case dnd = "dnd"
    case online = "online"
    case offline = "offline"
}

public struct PresenceUser: Codable, GatewayData {
    public let id: Snowflake
    public let username: String?
    public let discriminator: String?
    public let avatar: String?
}

public struct PresenceUpdate: GatewayData {
    public let user: PresenceUser
    public let guild_id: Snowflake?
    public let status: PresenceStatus
    public let activities: [Activity]
    public let client_status: PresenceClientStatus
}

public struct PartialPresenceUpdate: GatewayData {
    public let user: PresenceUser
    public let guild_id: Snowflake?
    public let status: PresenceStatus?
    public let activities: [Activity]?
    public let client_status: PresenceClientStatus?
}

public struct PresenceClientStatus: Codable, GatewayData {
    public let desktop: PresenceStatus?
    public let mobile: PresenceStatus?
    public let web: PresenceStatus?
}
