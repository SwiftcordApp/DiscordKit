//
//  Levels.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

public enum VerificationLevel: Int, Codable {
    case `none` = 0   // Unrestricted
    case low = 1      // Must have verified email
    case medium = 2   // Registeded on Discord for > 5 mins
    case high = 3     // Member of server for > 10 mins
    case veryHigh = 4 // Must have verified hp
}

public enum MessageNotifLevel: RawRepresentable, Codable, Equatable {
    case all
    case mentions
    case none
    case inherit
    case unknown(Int)

    public init(rawValue: Int) {
        switch rawValue {
        case 0: self = .all
        case 1: self = .mentions
        case 2: self = .none
        case 3: self = .inherit
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: Int {
        switch self {
        case .all: 0
        case .mentions: 1
        case .none: 2
        case .inherit: 3
        case .unknown(let rawValue): rawValue
        }
    }

    public init(from decoder: Decoder) throws {
        self.init(rawValue: try decoder.singleValueContainer().decode(Int.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

public enum ExplicitContentFilterLevel: Int, Codable {
    case disabled = 0
    case withoutRoles = 1 // Scan messages from members without roles
    case all = 2 // Scan everyone's messages
}

public enum MFALevel: Int, Codable {
    case `none` = 0
    case elevated = 1
}

public enum NSFWLevel: Int, Codable {
    case `default` = 0
    case explicit = 1
    case `safe` = 2
    case ageRestricted = 3
}

public enum PremiumLevel: Int, Codable {
    case `none` = 0
    case tier1 = 1
    case tier2 = 2
    case tier3 = 3
}
