//
//  File.swift
//  
//
//  Created by Vincent Kwok on 1/6/22.
//

import Foundation

public protocol AssetFormat: RawRepresentable, Sendable where RawValue == String {
    static var animatedWebP: Self? { get }
}

public extension AssetFormat {
    static var animatedWebP: Self? { nil }
}

/// A typical static asset, supporting jpeg, png and webp formats
public enum StaticAssetFormat: String, AssetFormat {
    case jpeg = "jpg"
    case png = "png"
    case webp = "webp"
}

/// An animated asset, supporting jpeg, png, webp and gif formats
public enum AnimatedAssetFormat: String, AssetFormat {
    case jpeg = "jpg"
    case png = "png"
    case webp = "webp"
    case gif = "gif"

    public static var animatedWebP: Self? { .webp }
}

/// A png-only asset, supporting only the png format
public enum PNGAssetFormat: String, AssetFormat {
    case png = "png"
}

public protocol HashedAssetKind: Sendable {
    associatedtype Scope: Sendable = Void
    associatedtype Format: AssetFormat = StaticAssetFormat

    static var defaultFormat: Format { get }
    static func pathComponents(for hash: String, scope: Scope) -> [String]
}

public extension HashedAssetKind where Format == StaticAssetFormat {
    static var defaultFormat: Format { .png }
}

public extension HashedAssetKind where Format == AnimatedAssetFormat {
    static var defaultFormat: Format { .png }
}

public extension HashedAssetKind where Format == PNGAssetFormat {
    static var defaultFormat: Format { .png }
}

public struct HashedAsset<Kind: HashedAssetKind>: RawRepresentable, Codable, Hashable, Sendable, ExpressibleByStringLiteral, CustomStringConvertible {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public var description: String {
        rawValue
    }

    public var isAnimated: Bool {
        rawValue.hasPrefix("a_")
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    public func scoped(to scope: Kind.Scope) -> ScopedHashedAsset<Kind> {
        ScopedHashedAsset(asset: self, scope: scope)
    }
}

public extension HashedAsset where Kind.Scope == Void {
    func scoped() -> ScopedHashedAsset<Kind> {
        scoped(to: ())
    }

    func url(
        with format: Kind.Format = Kind.defaultFormat,
        size: Int? = nil,
        animated: Bool = false
    ) -> URL {
        scoped().url(with: format, size: size, animated: animated)
    }
}

public struct ScopedHashedAsset<Kind: HashedAssetKind>: Sendable, CustomStringConvertible {
    public let asset: HashedAsset<Kind>
    public let scope: Kind.Scope

    public init(asset: HashedAsset<Kind>, scope: Kind.Scope) {
        self.asset = asset
        self.scope = scope
    }

    public var rawValue: String {
        asset.rawValue
    }

    public var description: String {
        rawValue
    }

    public var isAnimated: Bool {
        asset.isAnimated
    }

    public func url(
        with format: Kind.Format = Kind.defaultFormat,
        size: Int? = nil,
        animated: Bool = false
    ) -> URL {
        let shouldAnimate = animated && isAnimated && Kind.Format.animatedWebP != nil
        let resolvedFormat = shouldAnimate ? Kind.Format.animatedWebP! : format
        return Self.joinPaths(
            with: resolvedFormat,
            Kind.pathComponents(for: rawValue, scope: scope)
        )
        .setAnimated(animated: shouldAnimate)
        .setSize(size: size)
    }

    private static func joinPaths<Format: AssetFormat>(with format: Format, _ paths: [String]) -> URL {
        var base = URL(string: DiscordKitConfig.default.cdnURL)!

        for path in paths { base.appendPathComponent(path) }
        base.appendPathExtension(format.rawValue)

        return base
    }
}

extension ScopedHashedAsset: Equatable where Kind.Scope: Equatable {}
extension ScopedHashedAsset: Hashable where Kind.Scope: Hashable {}

public extension HashedAsset where Kind == GuildMemberAvatar {
    func scoped(to userID: Snowflake, in guildID: Snowflake) -> ScopedHashedAsset<Kind> {
        scoped(to: GuildMemberAssetScope(userID: userID, guildID: guildID))
    }
}

public extension HashedAsset where Kind == GuildMemberBanner {
    func scoped(to userID: Snowflake, in guildID: Snowflake) -> ScopedHashedAsset<Kind> {
        scoped(to: GuildMemberAssetScope(userID: userID, guildID: guildID))
    }
}

public extension HashedAsset where Kind == UserAvatar {
    /// Get the default avatar image of a provided user discriminator.
    static func defaultAvatar(of discriminator: String) -> URL {
        var url = URL(string: DiscordKitConfig.default.cdnURL)!
        url.appendPathComponent("embed")
        url.appendPathComponent("avatars")
        url.appendPathComponent(String((Int(discriminator) ?? 0) % 5))
        url.appendPathExtension(PNGAssetFormat.png.rawValue)
        return url
    }
}
