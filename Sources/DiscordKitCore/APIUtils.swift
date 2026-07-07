//
//  APIUtils.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 13/5/22.
//

import Foundation

let iso8601 = { () -> ISO8601DateFormatter in
    let fmt = ISO8601DateFormatter()
    fmt.formatOptions = [.withInternetDateTime]
    return fmt
}()

let iso8601WithFractionalSeconds = { () -> ISO8601DateFormatter in
    let fmt = ISO8601DateFormatter()
    fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return fmt
}()

enum DiscordDateDecoder {
    static func decode(from decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()

        if let dateString = try? container.decode(String.self) {
            if let date = date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode Discord date string \(dateString)"
            )
        }

        if let timestamp = try? container.decode(TimeInterval.self) {
            return date(fromTimestamp: timestamp)
        }

        throw DecodingError.typeMismatch(
            Date.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Expected Discord date string or timestamp"
            )
        )
    }

    static func date(from value: String) -> Date? {
        if let date = iso8601.date(from: value) {
            return date
        }
        if let date = iso8601WithFractionalSeconds.date(from: value) {
            return date
        }
        if let timestamp = TimeInterval(value) {
            return date(fromTimestamp: timestamp)
        }

        return nil
    }

    static func date(fromTimestamp timestamp: TimeInterval) -> Date {
        // Discord supplemental snapshots have been observed sending dates as
        // numbers. Treat large Unix timestamps as milliseconds.
        Date(timeIntervalSince1970: timestamp > 10_000_000_000 ? timestamp / 1_000 : timestamp)
    }
}

extension KeyedDecodingContainer {
    /// Loosely decodes a date from a variety of formats.
    ///
    /// Supports ISO8601, Unix epoch seconds and epoch milliseconds.
    func decodeDiscordDateIfPresent(forKey key: Key) throws -> Date? {
        guard contains(key), try !decodeNil(forKey: key) else { return nil }

        if let dateString = try? decode(String.self, forKey: key) {
            return DiscordDateDecoder.date(from: dateString)
        }

        if let timestamp = try? decode(TimeInterval.self, forKey: key) {
            return DiscordDateDecoder.date(fromTimestamp: timestamp)
        }

        return nil
    }
}

public extension DiscordREST {
    // Encoders and decoders with custom date en/decoders
    static let encoder: JSONEncoder = {
        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .custom({ date, encoder in
            var container = encoder.singleValueContainer()
            let dateString = iso8601WithFractionalSeconds.string(from: date)
            try container.encode(dateString)
        })
        return enc
    }()
    static let decoder: JSONDecoder = {
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .custom { decoder in
            try DiscordDateDecoder.decode(from: decoder)
        }
        return dec
    }()
}
