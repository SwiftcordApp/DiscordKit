//
//  Snowflake+decode.swift
//  
//
//  Created by Vincent Kwok on 26/5/22.
//

import Foundation

public extension Snowflake {
    static let DISCORD_EPOCH = 1420070400000

    /// Decodes this Snowflake into a Date
    func decodeToDate() -> Date? {
        guard let intSnowflake = Int(self) else { return nil }
        let millisTimestamp = (intSnowflake >> 22) + Self.DISCORD_EPOCH
        return Date(timeIntervalSince1970: Double(millisTimestamp) / 1000.0)
    }

    /// Whether this snowflake is newer (numerically greater) than another; `nil` counts as older.
    func isNewer(than other: Snowflake?) -> Bool {
        guard let other else { return true }
        guard let lhs = UInt64(self), let rhs = UInt64(other) else { return self > other }
        return lhs > rhs
    }
}
