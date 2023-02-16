//
//  ReadState.swift
//  
//
//  Created by Vincent Kwok on 16/2/23.
//

import Foundation

public struct ReadState: Codable {
    /// A read state entry for a channel
    public struct Entry: Codable {
        public let id: Snowflake
        public let last_message_id: HybridSnowflake?
        public let last_pin_timestamp: Date?
        public let mention_count: Int?
    }

    /// Read state entries
    public let entries: [Entry]

    /// If this read state update is partial
    public let partial: Bool

    /// Version of this read state, will be incremented for major updates
    public let version: Int
}
