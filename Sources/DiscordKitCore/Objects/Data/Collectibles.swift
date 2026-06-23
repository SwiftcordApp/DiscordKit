//
//  Collectibles.swift
//  DiscordKit
//
//  Created by Vincent on 23/6/26.
//

import Foundation

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
    public let src: String
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
