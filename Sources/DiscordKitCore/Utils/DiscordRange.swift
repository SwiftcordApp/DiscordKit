//
//  DiscordRange.swift
//
//
//  Created by Vincent Kwok on 14/3/24.
//

import Foundation

public struct DiscordRange: Codable, CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        closedRange.description
    }
    public var debugDescription: String {
        closedRange.debugDescription
    }

    public let start: Int
    public let end: Int

    public var closedRange: ClosedRange<Int> { start...end }

    public init(start: Int, end: Int) {
        self.start = start
        self.end = end
    }

    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.start = try container.decode(Int.self)
        self.end = try container.decode(Int.self)
        guard container.isAtEnd else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Unexpected elements at end of range"))
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(start)
        try container.encode(end)
    }
}
