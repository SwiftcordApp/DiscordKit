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
    public let client_status: PresenceClientStatus?
    @LossyArrayDecodable public var activities: [Activity]
    @LossyArrayDecodable public var hidden_activities: [Activity]
    public let processed_at_timestamp: Double?

    public init(
        userID: Snowflake,
        status: PresenceStatus,
        clientStatus: PresenceClientStatus?,
        activities: [Activity],
        hiddenActivities: [Activity] = [],
        processedAtTimestamp: Double? = nil
    ) {
        self.user_id = userID
        self.status = status
        self.client_status = clientStatus
        self._activities = LossyArrayDecodable(wrappedValue: activities)
        self._hidden_activities = LossyArrayDecodable(wrappedValue: hiddenActivities)
        self.processed_at_timestamp = processedAtTimestamp
    }

    public init(update: PresenceUpdate) {
        user_id = update.user.id
        status = update.status
        client_status = update.client_status
        _activities = LossyArrayDecodable(wrappedValue: update.activities)
        _hidden_activities = LossyArrayDecodable(wrappedValue: update.hidden_activities)
        processed_at_timestamp = update.processed_at_timestamp
    }
}

public enum PresenceStatus: String, Codable {
    case idle
    case dnd
    case online
    case offline
    case invisible
    case streaming
    /// Sentinel for statuses this build doesn't know; not an alias for offline
    case unknown

    public init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = Self(rawValue: raw) ?? .unknown
    }
}

public struct PresenceUser: Codable, GatewayData {
    public let id: Snowflake
    public let username: String?
    public let discriminator: String?
    public let avatar: String?
    public let primary_guild: UserPrimaryGuild?
}

public struct PresenceUpdate: Codable, GatewayData {
    public let user: PresenceUser
    public let guild_id: Snowflake?
    public let status: PresenceStatus
    @LossyArrayDecodable public var activities: [Activity]
    @LossyArrayDecodable public var hidden_activities: [Activity]
    public let client_status: PresenceClientStatus?
    public let processed_at_timestamp: Double?
}

/// Presence nested in a guild member-list item.
///
/// Unlike ``PresenceUpdate``, this wire shape does not carry a `user`; the
/// containing ``Member`` supplies the user ID.
public struct MemberPresence: Codable, GatewayData {
    public let status: PresenceStatus
    @LossyArrayDecodable public var activities: [Activity]
    @LossyArrayDecodable public var hidden_activities: [Activity]
    public let client_status: PresenceClientStatus?
    public let processed_at_timestamp: Double?
}

public struct PartialPresenceUpdate: GatewayData {
    public let user: PresenceUser
    public let guild_id: Snowflake?
    public let status: PresenceStatus?
    public let activities: [Activity]?
    public let hidden_activities: [Activity]?
    public let client_status: PresenceClientStatus?
    public let processed_at_timestamp: Double?
}

public struct PresenceClientStatus: Codable, Equatable, GatewayData {
    public init(desktop: PresenceStatus? = nil, mobile: PresenceStatus? = nil, web: PresenceStatus? = nil, vr: PresenceStatus? = nil) {
        self.desktop = desktop
        self.mobile = mobile
        self.web = web
        self.vr = vr
    }

    public let desktop: PresenceStatus?
    public let mobile: PresenceStatus?
    public let web: PresenceStatus?
    public let vr: PresenceStatus?
}
