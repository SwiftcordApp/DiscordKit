//
//  DefaultDecodable.swift
//  DiscordKit
//
//  Created by Vincent on 23/6/26.
//

import Foundation

public protocol DefaultDecodingType {
    associatedtype Value: Decodable

    static var defaultValue: Value { get }
}

@propertyWrapper
public struct DefaultDecodable<Source: DefaultDecodingType>: Decodable {
    public let wrappedValue: Source.Value

    public init() {
        wrappedValue = Source.defaultValue
    }

    public init(wrappedValue: Source.Value) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        wrappedValue = try decoder.singleValueContainer().decode(Source.Value.self)
    }
}

extension DefaultDecodable: Encodable where Source.Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

public extension KeyedDecodingContainer {
    func decode<Source>(
        _ type: DefaultDecodable<Source>.Type,
        forKey key: Key
    ) throws -> DefaultDecodable<Source> {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }
}

public enum DefaultFalse: DefaultDecodingType {
    public static let defaultValue = false
}

public enum DefaultZero<Value: Decodable & AdditiveArithmetic>: DefaultDecodingType {
    public static var defaultValue: Value { .zero }
}

public enum DefaultEmptyArray<Element: Decodable>: DefaultDecodingType {
    public static var defaultValue: [Element] { [] }
}

public protocol DefaultInitializable {
    init()
}

public enum DefaultInitial<Value: Decodable & DefaultInitializable>: DefaultDecodingType {
    public static var defaultValue: Value { .init() }
}

public typealias DefaultFalseDecodable = DefaultDecodable<DefaultFalse>
public typealias DefaultZeroDecodable<Value: Decodable & AdditiveArithmetic> =
    DefaultDecodable<DefaultZero<Value>>
public typealias DefaultEmptyArrayDecodable<Element: Decodable> =
    DefaultDecodable<DefaultEmptyArray<Element>>
public typealias DefaultInitialDecodable<Value: Decodable & DefaultInitializable> =
    DefaultDecodable<DefaultInitial<Value>>
