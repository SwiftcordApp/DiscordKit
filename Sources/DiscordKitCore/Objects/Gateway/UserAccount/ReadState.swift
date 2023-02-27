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
        public init(
            id: Snowflake,
            lastMessageID: Snowflake? = nil, lastPinTimestamp: Date? = nil,
            mention_count: Int? = nil
        ) {
            self.id = id
            if let lastMessageID {
                self.last_message_id = .string(lastMessageID)
            } else {
                self.last_message_id = nil
            }
            self.last_pin_timestamp = lastPinTimestamp
            self.mention_count = mention_count
        }

        public let id: Snowflake
        public let last_message_id: HybridSnowflake?
        public let last_pin_timestamp: Date?
        public let mention_count: Int?

        public func updatingLastMessage(id messageID: Snowflake) -> Self {
            .init(
                id: id,
                lastMessageID: messageID,
                lastPinTimestamp: last_pin_timestamp,
                mention_count: mention_count
            )
        }
    }

    /// Read state entries
    public let entries: [Entry]

    /// If this read state update is partial
    public let partial: Bool

    /// Version of this read state, will be incremented for major updates
    public let version: Int
}
