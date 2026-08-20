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

extension DefaultDecodable: Equatable where Source.Value: Equatable { }

public extension KeyedDecodingContainer {
    func decode<Source>(
        _ type: DefaultDecodable<Source>.Type,
        forKey key: Key
    ) throws -> DefaultDecodable<Source> {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }
}

/// Defaults a missing array to empty and discards only elements that fail to decode.
///
/// Use this for supplemental arrays whose schema drift must not discard their
/// containing event. Keep authoritative collections on ``DefaultDecodable``.
@propertyWrapper
public struct LossyArrayDecodable<Element: Decodable>: Decodable {
    public let wrappedValue: [Element]

    public init() {
        wrappedValue = []
    }

    public init(wrappedValue: [Element]) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let elements = try? decoder.singleValueContainer().decode([DecodeThrowable<Element>].self)
        wrappedValue = elements?.compactMap { try? $0.unwrap() } ?? []
    }
}

extension LossyArrayDecodable: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

public extension KeyedDecodingContainer {
    func decode<Element>(
        _ type: LossyArrayDecodable<Element>.Type,
        forKey key: Key
    ) throws -> LossyArrayDecodable<Element> {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }
}

/// Defaults a missing nested array to empty, preserves its outer indices, and
/// discards only inner elements that fail to decode.
///
/// This is useful for index-aligned Gateway collections such as
/// `merged_members`, where dropping an entire inner array would associate the
/// following values with the wrong guild.
@propertyWrapper
public struct LossyNestedArrayDecodable<Element: Decodable>: Decodable {
    public let wrappedValue: [[Element]]

    public init() {
        wrappedValue = []
    }

    public init(wrappedValue: [[Element]]) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let groups = try? decoder.singleValueContainer().decode(
            [DecodeThrowable<[DecodeThrowable<Element>]>].self
        )
        wrappedValue = groups?.map { group in
            guard let elements = try? group.unwrap() else { return [] }
            return elements.compactMap { try? $0.unwrap() }
        } ?? []
    }
}

extension LossyNestedArrayDecodable: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

public extension KeyedDecodingContainer {
    func decode<Element>(
        _ type: LossyNestedArrayDecodable<Element>.Type,
        forKey key: Key
    ) throws -> LossyNestedArrayDecodable<Element> {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }
}

/// Decodes an optional value without allowing a malformed optional field to
/// discard its containing payload.
@propertyWrapper
public struct LossyOptionalDecodable<Value: Decodable>: Decodable {
    public let wrappedValue: Value?

    public init() {
        wrappedValue = nil
    }

    public init(wrappedValue: Value?) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        wrappedValue = try? decoder.singleValueContainer().decode(Value.self)
    }
}

extension LossyOptionalDecodable: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

extension LossyOptionalDecodable: Equatable where Value: Equatable { }
extension LossyOptionalDecodable: Hashable where Value: Hashable { }

public extension KeyedDecodingContainer {
    func decode<Value>(
        _ type: LossyOptionalDecodable<Value>.Type,
        forKey key: Key
    ) throws -> LossyOptionalDecodable<Value> {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }
}

public extension KeyedEncodingContainer {
    mutating func encode<Value>(
        _ value: LossyOptionalDecodable<Value>,
        forKey key: Key
    ) throws where Value: Encodable {
        try encodeIfPresent(value.wrappedValue, forKey: key)
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

public enum DefaultEmptyString: DefaultDecodingType {
    public static let defaultValue = ""
}

public enum DefaultEmptyOptionSet<Value: Decodable & OptionSet>: DefaultDecodingType {
    public static var defaultValue: Value { [] }
}

public enum DefaultDistantPastDate: DefaultDecodingType {
    public static let defaultValue = Date.distantPast
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
public typealias DefaultEmptyStringDecodable = DefaultDecodable<DefaultEmptyString>
public typealias DefaultEmptyOptionSetDecodable<Value: Decodable & OptionSet> =
    DefaultDecodable<DefaultEmptyOptionSet<Value>>
public typealias DefaultDistantPastDateDecodable = DefaultDecodable<DefaultDistantPastDate>
public typealias DefaultInitialDecodable<Value: Decodable & DefaultInitializable> =
    DefaultDecodable<DefaultInitial<Value>>
