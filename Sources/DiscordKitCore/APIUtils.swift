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
        dec.dateDecodingStrategy = .custom({ decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            if let date = iso8601.date(from: dateString) {
                return date
            }
            if let date = iso8601WithFractionalSeconds.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        })
        return dec
    }()
}
