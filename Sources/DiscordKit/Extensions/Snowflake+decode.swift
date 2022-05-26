//
//  File.swift
//  
//
//  Created by Vincent Kwok on 26/5/22.
//

import Foundation

extension Snowflake {
    /// Decodes this Snowflake into a Date
    public func decodeToDate() -> Date? {
        guard let intSnowflake = Int(self) else { return nil }
        let millisTimestamp = (intSnowflake >> 22) + 1420070400000
        return Date(timeIntervalSince1970: Double(millisTimestamp) / 1000.0)
    }
}
