//
//  Collectibles.swift
//  DiscordKit
//
//  Created by Vincent on 23/6/26.
//

import Foundation

/// User profile effect collectible
public struct UserProfileEffectProduct: Codable, GatewayData {
    private enum CodingKeys: String, CodingKey {
        case sku_id
        case name
        case summary
        case store_listing_id
        case styles
        case items
        case type
        case premium_type
        case category_sku_id
        case google_sku_ids
    }

    /// Collectible sku id
    public let sku_id: Snowflake
    public let name: String
    public let summary: String?
    public let store_listing_id: Snowflake?
    public let styles: UserProfileEffectProductStyles?
    public let items: [UserProfileEffectProductItem]
    public let type: Int?
    public let premium_type: Int?
    public let category_sku_id: Snowflake?
    public let google_sku_ids: [String : String]?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sku_id = try container.decode(Snowflake.self, forKey: .sku_id)
        name = try container.decode(String.self, forKey: .name)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        store_listing_id = try container.decodeIfPresent(Snowflake.self, forKey: .store_listing_id)
        styles = try container.decodeIfPresent(UserProfileEffectProductStyles.self, forKey: .styles)
        items = try container.decodeIfPresent([UserProfileEffectProductItem].self, forKey: .items) ?? []
        type = try container.decodeIfPresent(Int.self, forKey: .type)
        premium_type = try container.decodeIfPresent(Int.self, forKey: .premium_type)
        category_sku_id = try container.decodeIfPresent(Snowflake.self, forKey: .category_sku_id)
        google_sku_ids = try container.decodeIfPresent([String : String].self, forKey: .google_sku_ids)
    }
}

public struct UserProfileEffectProductStyles: Codable, GatewayData {
    public let background_colors: [Int]?
    public let button_colors: [Int]?
    public let confetti_colors: [Int]?
}

public struct UserProfileEffectProductItem: Codable, GatewayData {
    private enum CodingKeys: String, CodingKey {
        case type
        case sku_id
        case title
        case description
        case accessibilityLabel
        case animationType
        case staticFrameSrc
        case thumbnailPreviewSrc
        case reducedMotionSrc
        case effects
    }

    public let type: Int?
    public let sku_id: Snowflake?
    public let title: String?
    public let description: String?
    public let accessibilityLabel: String?
    public let animationType: Int?
    public let staticFrameSrc: String?
    public let thumbnailPreviewSrc: String?
    public let reducedMotionSrc: String?
    public let effects: [UserProfileEffectProductEffect]

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decodeIfPresent(Int.self, forKey: .type)
        sku_id = try container.decodeIfPresent(Snowflake.self, forKey: .sku_id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        accessibilityLabel = try container.decodeIfPresent(String.self, forKey: .accessibilityLabel)
        animationType = try container.decodeIfPresent(Int.self, forKey: .animationType)
        staticFrameSrc = try container.decodeIfPresent(String.self, forKey: .staticFrameSrc)
        thumbnailPreviewSrc = try container.decodeIfPresent(String.self, forKey: .thumbnailPreviewSrc)
        reducedMotionSrc = try container.decodeIfPresent(String.self, forKey: .reducedMotionSrc)
        effects = try container.decodeIfPresent([UserProfileEffectProductEffect].self, forKey: .effects) ?? []
    }
}

public struct UserProfileEffectProductEffect: Codable, GatewayData {
    private enum CodingKeys: String, CodingKey {
        case src
        case loop
        case height
        case width
        case duration
        case start
        case loopDelay
        case position
        case zIndex
        case randomizedSources
    }

    public let src: String
    public let loop: Bool
    public let height: Double
    public let width: Double
    public let duration: Double?
    public let start: Double
    public let loopDelay: Double?
    public let position: UserProfileEffectProductEffectPosition
    public let zIndex: Int
    public let randomizedSources: [String]

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        src = try container.decode(String.self, forKey: .src)
        loop = try container.decodeIfPresent(Bool.self, forKey: .loop) ?? false
        height = try container.decodeIfPresent(Double.self, forKey: .height) ?? 0
        width = try container.decodeIfPresent(Double.self, forKey: .width) ?? 0
        duration = try container.decodeIfPresent(Double.self, forKey: .duration)
        start = try container.decodeIfPresent(Double.self, forKey: .start) ?? 0
        loopDelay = try container.decodeIfPresent(Double.self, forKey: .loopDelay)
        position = try container.decodeIfPresent(
            UserProfileEffectProductEffectPosition.self,
            forKey: .position
        ) ?? UserProfileEffectProductEffectPosition(x: 0, y: 0)
        zIndex = try container.decodeIfPresent(Int.self, forKey: .zIndex) ?? 0
        randomizedSources = try container.decodeIfPresent([String].self, forKey: .randomizedSources) ?? []
    }
}

public struct UserProfileEffectProductEffectPosition: Codable, GatewayData {
    public let x: Double
    public let y: Double
}
