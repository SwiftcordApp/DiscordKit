//
//  Activity.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 20/2/22.
//

import Foundation

public enum ActivityType: Int, Codable {
    case game = 0      // Playing {name}
    case streaming = 1 // Streaming {details}
    case listening = 2 // Listening to {name}
    case watching = 3  // Watching {name}
    case custom = 4    // {emoji} {name}
    case competing = 5 // Competing in {name}
}

public struct Activity: GatewayData {
    public init(name: String, type: ActivityType, url: String? = nil, created_at: Int, timestamps: ActivityTimestamp? = nil, application_id: Snowflake? = nil, details: String? = nil, state: String? = nil, emoji: ActivityEmoji? = nil, party: ActivityParty? = nil, assets: ActivityAssets? = nil, secrets: ActivitySecrets? = nil, instance: Bool? = nil, flags: Int? = nil, buttons: [String]? = nil) {
        self.name = name
        self.type = type
        self.url = url
        self.created_at = created_at
        self.timestamps = timestamps
        self.application_id = application_id
        self.details = details
        self.state = state
        self.emoji = emoji
        self.party = party
        self.assets = assets
        self.secrets = secrets
        self.instance = instance
        self.flags = flags
        self.buttons = buttons
    }

    public let name: String
    public let type: ActivityType
    public let url: String?
    public let created_at: Int // Unix timestamp (in milliseconds) of when the activity was added to the user's session
    public let timestamps: ActivityTimestamp?
    public let application_id: Snowflake?
    public let details: String?
    public let state: String?
    public let emoji: ActivityEmoji?
    public let party: ActivityParty?
    public let assets: ActivityAssets?
    public let secrets: ActivitySecrets?
    public let instance: Bool?
    public let flags: Int?
    public let buttons: [String]?
}

public struct ActivityOutgoing: OutgoingGatewayData {
    public init(name: String, type: ActivityType, url: String? = nil, created_at: Int? = nil, timestamps: ActivityTimestamp? = nil, application_id: Snowflake? = nil, details: String? = nil, state: String? = nil, emoji: ActivityEmoji? = nil, party: ActivityParty? = nil, assets: ActivityAssets? = nil, secrets: ActivitySecrets? = nil, instance: Bool? = nil, flags: Int? = nil, buttons: [ActivityButton]? = nil) {
        self.name = name
        self.type = type
        self.url = url
        self.created_at = created_at
        self.timestamps = timestamps
        self.application_id = application_id
        self.details = details
        self.state = state
        self.emoji = emoji
        self.party = party
        self.assets = assets
        self.secrets = secrets
        self.instance = instance
        self.flags = flags
        self.buttons = buttons
    }

    public init(from activity: Activity) {
        self.name = activity.name
        self.type = activity.type
        self.url = activity.url
        self.created_at = activity.created_at
        self.timestamps = activity.timestamps
        self.application_id = activity.application_id
        self.details = activity.details
        self.state = activity.state
        self.emoji = activity.emoji
        self.party = activity.party
        self.assets = activity.assets
        self.secrets = activity.secrets
        self.instance = activity.instance
        self.flags = activity.flags
        self.buttons = nil
    }

    public let name: String
    public let type: ActivityType
    public let url: String?
    public let created_at: Int? // Unix timestamp (in milliseconds) of when the activity was added to the user's session
    public let timestamps: ActivityTimestamp?
    public let application_id: Snowflake?
    public let details: String?
    public let state: String?
    public let emoji: ActivityEmoji?
    public let party: ActivityParty?
    public let assets: ActivityAssets?
    public let secrets: ActivitySecrets?
    public let instance: Bool?
    public let flags: Int?
    public let buttons: [ActivityButton]?
}

public struct ActivityTimestamp: Codable {
    public let start: Int? // Unix time (in milliseconds) of when the activity started
    public let end: Int? // Unix time (in milliseconds) of when the activity ended
}

public struct ActivityEmoji: Codable {
    public let name: String
    public let id: Snowflake?
    public let animated: Bool?
}

public struct ActivityParty: Codable {
    public let id: String? // The ID of the party (for some reason it's not a Snowflake)
    public let size: [Int]? // Array of two integers (current_size, max_size)
}

public struct ActivityAssets: Codable {
    public let large_image: String?
    public let large_text: String? // Text displayed when hovering over the large image of the activity
    public let small_image: String?
    public let small_text: String?
}

public struct ActivitySecrets: Codable {
    public let join: String?
    public let spectate: String?
    public let match: String? // The secret for a specific instanced match
}

public struct ActivityButton: Codable {
    public let label: String
    public let url: String
}
