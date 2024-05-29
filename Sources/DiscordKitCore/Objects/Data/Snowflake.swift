//
//  Snowflake.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

public typealias Snowflake = String

extension Snowflake {
    init(timestamp: Date = .init()) {
        let epoch = Int(timestamp.timeIntervalSince1970*1000) - Self.DISCORD_EPOCH
        self.init(epoch << 22)
    }
}
