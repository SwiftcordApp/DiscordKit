//
//  Snowflake.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

public typealias Snowflake = String

public extension Snowflake {
    func creationTime() -> Date? {
        // Convert to a unsigned integer
        guard let snowflake = UInt64(self) else { return nil }
        // shifts the bits so that only the first 42 are used
        let snowflakeTimestamp = snowflake >> 22
        // Discord snowflake timestamps start from the first second of 2015
        let discordEpoch = Date(timeIntervalSince1970: 1420070400)

        // Convert from ms to sec, because Date wants sec, but discord provides ms
        return Date(timeInterval: Double(snowflakeTimestamp) / 1000, since: discordEpoch)
    }
}
