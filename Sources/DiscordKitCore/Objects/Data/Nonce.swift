//
//  Nonce.swift
//
//
//  Created by Vincent Kwok on 19/3/24.
//

import Foundation

public enum Nonce: Codable, Equatable {
    case string(String)
    case int(Int)

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }

    public var value: String {
        switch self {
        case .string(let val):
            return val
        case .int(let val):
            return String(val)
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let val):
            try container.encode(val)
        case .int(let val):
            try container.encode(val)
        }
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            self = .string(str)
        } else {
            self = .int(try container.decode(Int.self))
        }
    }

    public init() {
        self = .string(Snowflake(timestamp: Date()))
    }
}
