//
//  ReadState.swift
//  
//
//  Created by Vincent Kwok on 16/2/23.
//

import Foundation

public enum ReadStateType: Codable, Equatable {
    case channel
    case guildEvent
    case notificationCenter
    case guildHome
    case guildOnboardingQuestion
    case messageRequests
    case unknown(Int)

    public var rawValue: Int {
        switch self {
        case .channel: return 0
        case .guildEvent: return 1
        case .notificationCenter: return 2
        case .guildHome: return 3
        case .guildOnboardingQuestion: return 4
        case .messageRequests: return 5
        case .unknown(let value): return value
        }
    }

    public init(rawValue: Int) {
        switch rawValue {
        case 0: self = .channel
        case 1: self = .guildEvent
        case 2: self = .notificationCenter
        case 3: self = .guildHome
        case 4: self = .guildOnboardingQuestion
        case 5: self = .messageRequests
        default: self = .unknown(rawValue)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(rawValue: try container.decode(Int.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

public enum DefaultReadStateType: DefaultDecodingType {
    public static let defaultValue: ReadStateType = .channel
}

public typealias DefaultReadStateTypeDecodable = DefaultDecodable<DefaultReadStateType>

public struct ReadState: Codable {
    /// A read state entry for a channel
    public struct Entry: Codable {
        public static let lowImportanceMentionFlag = 4

        public init(
            id: Snowflake,
            readStateType: ReadStateType = .channel,
            lastAckedID: Snowflake? = nil,
            lastPinTimestamp: Date? = nil,
            mention_count: Int? = nil,
            badge_count: Int? = nil,
            flags: Int? = nil,
            last_viewed: Int? = nil
        ) {
            self.id = id
            _read_state_type = DefaultReadStateTypeDecodable(wrappedValue: readStateType)
            self.last_acked_id = lastAckedID.map { .string($0) }
            self.last_message_id = nil
            self.last_pin_timestamp = lastPinTimestamp
            self.mention_count = mention_count
            self.badge_count = badge_count
            self.flags = flags
            self.last_viewed = last_viewed
        }

        public let id: Snowflake
        @DefaultReadStateTypeDecodable public var read_state_type: ReadStateType
        public let last_acked_id: HybridSnowflake?
        public let last_message_id: HybridSnowflake?
        public let last_pin_timestamp: Date?
        public let mention_count: Int?
        public let badge_count: Int?
        public let flags: Int?
        /// Days since the Discord epoch when the channel was last viewed (not a timestamp).
        public let last_viewed: Int?

        public var ackMessageID: Snowflake? {
            last_acked_id?.stringValue ?? last_message_id?.stringValue
        }

        /// Channel read states carry `mention_count`; non-channel ones carry `badge_count`.
        public var effectiveMentionCount: Int {
            max((read_state_type == .channel ? mention_count : badge_count) ?? 0, 0)
        }

        public var hasLowImportanceMention: Bool {
            guard let flags else { return false }
            return flags & Self.lowImportanceMentionFlag != 0
        }
    }

    /// Read state entries
    @DefaultEmptyArrayDecodable public var entries: [Entry]

    /// If this read state update is partial
    @DefaultFalseDecodable public var partial: Bool

    /// Version of this read state, will be incremented for major updates
    @DefaultZeroDecodable public var version: Int

    public init(entries: [Entry], partial: Bool = false, version: Int = 0) {
        _entries = DefaultEmptyArrayDecodable(wrappedValue: entries)
        _partial = DefaultFalseDecodable(wrappedValue: partial)
        _version = DefaultZeroDecodable(wrappedValue: version)
    }
}
