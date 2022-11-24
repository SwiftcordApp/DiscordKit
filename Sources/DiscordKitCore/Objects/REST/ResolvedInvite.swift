//
//  ResolvedInvite.swift
//  
//
//  Created by Vincent Kwok on 10/7/22.
//

import Foundation

public enum InviteTargetType: Int, Codable {
    case stream = 1
    case embeddedApplication = 2
}

/// Invite
///
/// Represents a code that when used, adds a user to a guild or group DM channel.
public struct Invite: Decodable {
    /// The invite code (unique ID)
    public let code: String
    // The guild this invite is for
    // public let guild: Guild?
    /// The channel this invite is for
    public let channel: Channel?
    /// The type of target for this voice channel invite
    public let target_type: InviteTargetType?
    /// The user whose stream to display for this voice channel stream invite
    public let target_user: User?
    /// The user who created the invite
    public let inviter: User?
    /// Approximate count of online members
    ///
    /// > Returned from ``DiscordREST/resolveInvite(inviteID:inputValue:withCounts:withExpiration:)``
    /// (`GET /invites/{inviteID}` endpoint) when `with_counts` is true
    public let approximate_member_count: Int?
    /// Approximate count of total members
    ///
    /// > Returned from ``DiscordREST/resolveInvite(inviteID:inputValue:withCounts:withExpiration:)``)
    /// > (`GET /invites/{inviteID}` endpoint) when `with_counts` is true
    public let approximate_presence_count: Int?
    /// The embedded application to open for this voice channel embedded application invite
    public let target_application: PartialApplication?
    /// The expiration date of this invite
    ///
    /// > Returned from ``DiscordREST/resolveInvite(inviteID:inputValue:withCounts:withExpiration:)``
    /// > (`GET /invites/{inviteID}` endpoint) when `with_expiration` is true
    public let expires_at: Date?
    /// Guild scheduled event data
    ///
    /// > Only included if `guild_scheduled_event_id` contains a valid guild scheduled event id
    public let guild_scheduled_event: GuildScheduledEvent?
}
