//
//  Snowflake+decode.swift
//  
//
//  Created by Vincent Kwok on 26/5/22.
//

import Foundation

let DISCORD_EPOCH = 1420070400000

public extension Snowflake {
    /// Decodes this Snowflake into a Date
    func decodeToDate() -> Date? {
        guard let intSnowflake = Int(self) else { return nil }
        let millisTimestamp = (intSnowflake >> 22) + DISCORD_EPOCH
        return Date(timeIntervalSince1970: Double(millisTimestamp) / 1000.0)
    }
}
