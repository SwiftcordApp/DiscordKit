//
//  Activity.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 20/2/22.
//

import Foundation

public enum ActivityType: RawRepresentable, Codable, Hashable {
    case game      // Playing {name}
    case streaming // Streaming {details}
    case listening // Listening to {name}
    case watching  // Watching {name}
    case custom    // {emoji} {name}
    case competing // Competing in {name}
    case hangStatus
    case unknown(Int)

    public init?(rawValue: Int) {
        switch rawValue {
        case 0: self = .game
        case 1: self = .streaming
        case 2: self = .listening
        case 3: self = .watching
        case 4: self = .custom
        case 5: self = .competing
        case 6: self = .hangStatus
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: Int {
        switch self {
        case .game: return 0
        case .streaming: return 1
        case .listening: return 2
        case .watching: return 3
        case .custom: return 4
        case .competing: return 5
        case .hangStatus: return 6
        case .unknown(let value): return value
        }
    }

    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(Int.self)
        self = Self(rawValue: value)!
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

public struct Activity: Codable, GatewayData {
    public init(name: String, type: ActivityType, url: String? = nil, created_at: Int? = nil, timestamps: ActivityTimestamp? = nil, application_id: Snowflake? = nil, details: String? = nil, state: String? = nil, emoji: ActivityEmoji? = nil, party: ActivityParty? = nil, assets: ActivityAssets? = nil, secrets: ActivitySecrets? = nil, instance: Bool? = nil, flags: Int? = nil, buttons: [String]? = nil) {
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
