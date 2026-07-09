//
//  Collectibles.swift
//  DiscordKit
//
//  Created by Vincent on 23/6/26.
//

import Foundation

/// Compact user/member collectibles sent on user and guild-member payloads.
public struct UserCollectibles: Codable, GatewayData, Equatable {
    public let nameplate: ProfileNameplate?

    public init(nameplate: ProfileNameplate? = nil) {
        self.nameplate = nameplate
    }

    private enum DecodingKeys: String, CodingKey {
        case nameplate
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DecodingKeys.self)
        nameplate = try? container.decodeIfPresent(ProfileNameplate.self, forKey: .nameplate)
    }
}

/// Compact profile nameplate data attached to a user or guild member.
public struct ProfileNameplate: Codable, GatewayData, Equatable {
    public let sku_id: Snowflake
    public let label: String
    public let palette: String
    public let asset: String?
    public let expires_at: Double?

    public init(
        sku_id: Snowflake,
        label: String,
        palette: String,
        asset: String? = nil,
        expires_at: Double? = nil
    ) {
        self.sku_id = sku_id
        self.label = label
        self.palette = palette
        self.asset = asset
        self.expires_at = expires_at
    }

    private enum DecodingKeys: String, CodingKey {
        case sku_id
        case skuId
        case label
        case palette
        case asset
        case expires_at
        case expiresAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DecodingKeys.self)
        sku_id = try container.decodeString(forKeys: .sku_id, .skuId)
        label = try container.decode(String.self, forKey: .label)
        palette = try container.decode(String.self, forKey: .palette)
        asset = try? container.decodeIfPresent(String.self, forKey: .asset)
        expires_at = try container.decodeNumberIfPresent(forKeys: .expires_at, .expiresAt)
    }
}

public extension ProfileNameplate {
    var staticImageURL: URL {
        Self.staticImageURL(skuID: sku_id)
    }

    static func staticImageURL(skuID: Snowflake) -> URL {
        var url = URL(string: DiscordKitConfig.default.cdnURL)!
        for component in ["media", "v1", "collectibles-shop", skuID, "static"] {
            url.appendPathComponent(component)
        }
        return url
    }
}

private extension KeyedDecodingContainer {
    func decodeString(forKeys keys: Key...) throws -> String {
        for key in keys {
            if let value = try? decodeIfPresent(String.self, forKey: key) {
                return value
            }
        }
        throw DecodingError.keyNotFound(
            keys[0],
            DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Expected one of \(keys.map(\.stringValue).joined(separator: ", "))"
            )
        )
    }

    func decodeNumberIfPresent(forKeys keys: Key...) throws -> Double? {
        for key in keys {
            if let value = try? decodeIfPresent(Double.self, forKey: key) {
                return value
            }
        }
        return nil
    }
}

/// User profile effect collectible
public struct UserProfileEffectProduct: Codable, GatewayData {
    /// Collectible sku id
    public let sku_id: Snowflake
    public let name: String
    public let summary: String?
    public let store_listing_id: Snowflake?
    public let styles: UserProfileEffectProductStyles?
    @DefaultEmptyArrayDecodable public var items: [UserProfileEffectProductItem]
    public let type: Int?
    public let premium_type: Int?
    public let category_sku_id: Snowflake?
    public let google_sku_ids: [String : String]?
}

public struct UserProfileEffectProductStyles: Codable, GatewayData {
    public let background_colors: [Int]?
    public let button_colors: [Int]?
    public let confetti_colors: [Int]?
}

public struct UserProfileEffectProductItem: Codable, GatewayData {
    public let type: Int?
    public let sku_id: Snowflake?
    public let title: String?
    public let description: String?
    public let accessibilityLabel: String?
    public let animationType: Int?
    public let staticFrameSrc: String?
    public let thumbnailPreviewSrc: String?
    public let reducedMotionSrc: String?
    @DefaultEmptyArrayDecodable public var effects: [UserProfileEffectProductEffect]
}

public struct UserProfileEffectProductEffect: Codable, GatewayData {
    /// Layer image URL; newer payloads reference an asset ``id`` instead
    public let src: String?
    /// Asset ID, resolved to a CDN URL via ``imageURL(skuID:)``
    public let id: String?
    @DefaultFalseDecodable public var loop: Bool
    @DefaultZeroDecodable public var height: Double
    @DefaultZeroDecodable public var width: Double
    public let duration: Double?
    @DefaultZeroDecodable public var start: Double
    public let loopDelay: Double?
    @DefaultInitialDecodable public var position: UserProfileEffectProductEffectPosition
    @DefaultZeroDecodable public var zIndex: Int
    @DefaultEmptyArrayDecodable public var randomizedSources: [String]
}

public extension UserProfileEffectProductEffect {
    /// Resolves this layer's image URL the way the official client does:
    /// an explicit `src` wins; otherwise the asset `id` maps to the
    /// collectibles-shop CDN route.
    func imageURL(skuID: Snowflake) -> URL? {
        if let src {
            return URL(string: src)
        }

        guard let id else { return nil }

        var url = URL(string: DiscordKitConfig.default.cdnURL)!
        for component in ["media", "v1", "collectibles-shop", skuID, id, "static"] {
            url.appendPathComponent(component)
        }
        return url
    }
}

public struct UserProfileEffectProductEffectPosition: Codable, GatewayData, DefaultInitializable {
    public let x: Double
    public let y: Double

    public init() {
        self.init(x: 0, y: 0)
    }

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}
