//
//  Emoji.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

public struct Emoji: Codable {
    public init(id: Snowflake? = nil, name: String? = nil, roles: [Role]? = nil, user: User? = nil, require_colons: Bool? = nil, managed: Bool? = nil, animated: Bool? = nil, available: Bool? = nil) {
        self.id = id
        self.name = name
        self.roles = roles
        self.user = user
        self.require_colons = require_colons
        self.managed = managed
        self.animated = animated
        self.available = available
    }

    public let id: Snowflake?
    public let name: String? // Can be null only in reaction emoji objects
    public let roles: [Role]?
    public let user: User? // User that created this emoji
    public let require_colons: Bool? // Whether this emoji must be wrapped in colons
    public let managed: Bool?
    public let animated: Bool?
    public let available: Bool? // Whether this emoji can be used, may be false due to loss of Server Boosts
}
