//
//  NormalizedPresence.swift
//  DiscordKit
//
//  Created by Vincent on 16/7/26.
//

import Foundation

/// Common presence data representation
///
/// Adapts the Gateway's different wire envelopes:
/// Supplemental READY entries identify users with `user_id`, while ordinary
/// presence updates carry a nested `user`. Some events carry their guild on the
/// presence and others on the outer event.
public struct NormalizedPresence {
    public enum Scope: Hashable {
        case guild(Snowflake)
        /// Friend and open-DM presence stored by Discord under its `"@me"` scope.
        case nonGuild
    }

    public let userID: Snowflake
    public let scope: Scope
    public let status: PresenceStatus
    public let clientStatus: PresenceClientStatus?
    public let activities: [Activity]
    public let hiddenActivities: [Activity]
    public let processedAtTimestamp: Double?

    public init(
        userID: Snowflake,
        scope: Scope,
        status: PresenceStatus,
        clientStatus: PresenceClientStatus?,
        activities: [Activity],
        hiddenActivities: [Activity] = [],
        processedAtTimestamp: Double?
    ) {
        self.userID = userID
        self.scope = scope
        self.status = status
        self.clientStatus = clientStatus
        self.activities = activities
        self.hiddenActivities = hiddenActivities
        self.processedAtTimestamp = processedAtTimestamp
    }

    /// Adapts an ordinary presence update. An explicit outer-event scope takes
    /// precedence over the optional `guild_id` carried by the update itself.
    public init(update: PresenceUpdate, scope: Scope? = nil) {
        self.init(
            userID: update.user.id,
            scope: scope ?? update.guild_id.map(Scope.guild) ?? .nonGuild,
            status: update.status,
            clientStatus: update.client_status,
            activities: update.activities,
            hiddenActivities: update.hidden_activities,
            processedAtTimestamp: update.processed_at_timestamp
        )
    }

    /// Adapts the compressed `user_id` shape used by supplemental READY.
    public init(supplemental presence: Presence, scope: Scope) {
        self.init(
            userID: presence.user_id,
            scope: scope,
            status: presence.status,
            clientStatus: presence.client_status,
            activities: presence.activities,
            hiddenActivities: presence.hidden_activities,
            processedAtTimestamp: presence.processed_at_timestamp
        )
    }

    /// Adapts presence embedded in a member-list item. The outer member owns
    /// the user identity and the member-list event owns the guild scope.
    public init(member presence: MemberPresence, userID: Snowflake, guildID: Snowflake) {
        self.init(
            userID: userID,
            scope: .guild(guildID),
            status: presence.status,
            clientStatus: presence.client_status,
            activities: presence.activities,
            hiddenActivities: presence.hidden_activities,
            processedAtTimestamp: presence.processed_at_timestamp
        )
    }
}
