//
//  Voice.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

public struct VoiceState: Codable, GatewayData {
    public let guild_id: Snowflake?
    public let channel_id: Snowflake?
    public let user_id: Snowflake
    public let member: Member?
    public let session_id: String
    /// Deafened by server
    @DefaultFalseDecodable public var deaf: Bool
    @DefaultFalseDecodable public var mute: Bool
    @DefaultFalseDecodable public var self_deaf: Bool
    @DefaultFalseDecodable public var self_mute: Bool
    public let self_stream: Bool?
    @DefaultFalseDecodable public var self_video: Bool
    @DefaultFalseDecodable public var suppress: Bool
    /// Time when user requested to speak, if any
    public let request_to_speak_timestamp: Date?
    public let discoverable: Bool?
    public let connected_at: Date?

    private enum CodingKeys: String, CodingKey {
        case guild_id
        case channel_id
        case user_id
        case member
        case session_id
        case deaf
        case mute
        case self_deaf
        case self_mute
        case self_stream
        case self_video
        case suppress
        case request_to_speak_timestamp
        case discoverable
        case connected_at
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guild_id = try container.decodeIfPresent(Snowflake.self, forKey: .guild_id)
        channel_id = try container.decodeIfPresent(Snowflake.self, forKey: .channel_id)
        user_id = try container.decode(Snowflake.self, forKey: .user_id)
        member = try container.decodeIfPresent(Member.self, forKey: .member)
        session_id = try container.decode(String.self, forKey: .session_id)
        _deaf = try container.decode(DefaultFalseDecodable.self, forKey: .deaf)
        _mute = try container.decode(DefaultFalseDecodable.self, forKey: .mute)
        _self_deaf = try container.decode(DefaultFalseDecodable.self, forKey: .self_deaf)
        _self_mute = try container.decode(DefaultFalseDecodable.self, forKey: .self_mute)
        self_stream = try container.decodeIfPresent(Bool.self, forKey: .self_stream)
        _self_video = try container.decode(DefaultFalseDecodable.self, forKey: .self_video)
        _suppress = try container.decode(DefaultFalseDecodable.self, forKey: .suppress)
        request_to_speak_timestamp = try container.decodeDiscordDateIfPresent(forKey: .request_to_speak_timestamp)
        discoverable = try container.decodeIfPresent(Bool.self, forKey: .discoverable)
        connected_at = try container.decodeDiscordDateIfPresent(forKey: .connected_at)
    }
}

private extension KeyedDecodingContainer {
    /// Loosely decodes a date from a variety of formats
    ///
    /// Supports ISO8601, unix epoch seconds and epoch ms
    func decodeDiscordDateIfPresent(forKey key: Key) throws -> Date? {
        guard contains(key), try !decodeNil(forKey: key) else { return nil }

        if let dateString = try? decode(String.self, forKey: key) {
            if let date = iso8601.date(from: dateString) {
                return date
            }
            if let date = iso8601WithFractionalSeconds.date(from: dateString) {
                return date
            }
            if let timestamp = TimeInterval(dateString) {
                return Self.date(fromTimestamp: timestamp)
            }
            return nil
        }

        if let timestamp = try? decode(TimeInterval.self, forKey: key) {
            return Self.date(fromTimestamp: timestamp)
        }

        return nil
    }

    static func date(fromTimestamp timestamp: TimeInterval) -> Date {
        // Discord supplemental snapshots have been observed sending this as a
        // number. Treat large Unix timestamps as milliseconds.
        Date(timeIntervalSince1970: timestamp > 10_000_000_000 ? timestamp / 1_000 : timestamp)
    }
}
