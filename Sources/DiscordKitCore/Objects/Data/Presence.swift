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

    public init(userID: Snowflake, status: PresenceStatus, clientStatus: PresenceClientStatus, activities: [Activity]) {
        self.user_id = userID
        self.status = status
        self.client_status = clientStatus
        self.activities = activities
    }

    public init(update: PresenceUpdate) {
        user_id = update.user.id
        status = update.status
        client_status = update.client_status
        activities = update.activities
    }
}

public enum PresenceStatus: String, Codable {
    case idle
    case dnd
    case online
    case offline
    case invisible
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
    public init(desktop: PresenceStatus? = nil, mobile: PresenceStatus? = nil, web: PresenceStatus? = nil) {
        self.desktop = desktop
        self.mobile = mobile
        self.web = web
    }

    public let desktop: PresenceStatus?
    public let mobile: PresenceStatus?
    public let web: PresenceStatus?
}
