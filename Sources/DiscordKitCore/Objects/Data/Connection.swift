//
//  Connection.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 22/2/22.
//

import Foundation

public enum ConnectionVisibility: Int, Codable {
    case none = 0 // Only visible to owner
    case everyone = 1
}

// Note: purely by observation
public enum ConnectionType: String {
    case steam = "steam"
    case youtube = "youtube"
    case spotify = "spotify"
    case github = "github"
    case twitch = "twitch"
    case reddit = "reddit"
    case facebook = "facebook"
    case twitter = "twitter"
    case xbox = "xbox"
    case battleNet = "battlenet"
    case playstation = "playstation"
    case leagueOfLegends = "leagueoflegends"
    case unknown
}
extension ConnectionType: Codable {
    public init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

// Connections with external accounts (e.g. Reddit, YouTube, Steam etc.)
public struct Connection: Codable, GatewayData {
    public let id: String
    public let name: String
    public let type: ConnectionType
    public let revoked: Bool?
    public let integrations: [Integration]?
    public let verified: Bool
    public let friend_sync: Bool?
    public let show_activity: Bool?
    public let visibility: ConnectionVisibility?
}
