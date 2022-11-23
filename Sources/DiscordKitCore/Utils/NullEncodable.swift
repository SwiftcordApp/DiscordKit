//
//  NullEncoder.swift
//  From https://stackoverflow.com/a/62312021/
//  
//
//  Created by Vincent Kwok on 14/10/22.
//

import Foundation

/// Explicitly include a value even when nil when encoded
@propertyWrapper
public struct NullEncodable<T>: Encodable where T: Encodable {
    public let wrappedValue: T?

    public init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch wrappedValue {
        case .some(let value): try container.encode(value)
        case .none: try container.encodeNil()
        }
    }
}
