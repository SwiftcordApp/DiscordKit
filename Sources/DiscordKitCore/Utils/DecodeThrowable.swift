//
//  CodableThrowable.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 9/3/22.
//

import Foundation

/// Utility type wrapper for handling JSON decoding errors in arrays
///
/// Wrapping any type with this wrapper allows array items with JSON
/// decoding errors to be removed, instead of the whole struct failing
/// to decode. Use a compactMap with `try? result.get()` to remove
/// items that failed to decode.
public struct DecodeThrowable<T: Decodable>: Decodable {
    /// Decoded result, use `try? .get()` to retrive the value
    /// or nil if decoding failed
    public let result: Result<T, Error>

    public func unwrap() throws -> T {
        try result.get()
    }

    public init(_ wrapped: T) {
        result = .success(wrapped)
    }

    public init(from decoder: Decoder) throws {
        result = Result(catching: { try T(from: decoder) })
    }
}

public extension Array {
    func compactUnwrap<T>() -> [T] where Element == DecodeThrowable<T> {
        self.compactMap { try? $0.unwrap() }
    }
}
