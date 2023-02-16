//
//  HybridSnowflake.swift
//  
//
//  Created by Vincent Kwok on 16/2/23.
//

import Foundation

/// A holder that can hold either representation of [Snowflakes](https://discord.com/developers/docs/reference#snowflakes)
public enum HybridSnowflake: Codable {
    /// A snowflake represented as an integer
    case int(Int)

    /// A snowflake represented as a string
    case string(String)

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let val):
            try container.encode(val)
        case .string(let val):
            try container.encode(val)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let val = try? container.decode(String.self) {
            self = .string(val)
        } else {
            self = .int(try container.decode(Int.self))
        }
    }
}
