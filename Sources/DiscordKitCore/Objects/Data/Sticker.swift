//
//  Sticker.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

public enum StickerType: Int, Codable, Hashable {
    case standard = 1
    case guild
}

public enum StickerFormat: Int, Codable, Hashable {
    case png = 1
    case aPNG // Animated PNG
    case lottie
    case gif
}

public struct Sticker: Codable, GatewayData, Identifiable, Equatable {
    public init(
        id: Snowflake, name: String, tags: String = "", type: StickerType,
        format_type: StickerFormat, pack_id: Snowflake? = nil,
        description: String? = nil, available: Bool? = nil, guild_id: Snowflake? = nil
    ) {
        self.id = id
        self.name = name
        self.tags = tags
        self.type = type
        self.format_type = format_type
        self.pack_id = pack_id
        self.description = description
        self.available = available
        self.guild_id = guild_id
        asset = nil
        user = nil
        sort_value = nil
    }

    public var item: StickerItem {
        StickerItem(id: id, name: name, format_type: format_type)
    }

    public let id: Snowflake
    public let pack_id: Snowflake? // For standard stickers, id of the pack the sticker is from
    public let name: String
    public let description: String?
    public let tags: String // Autocomplete/suggestion tags for the sticker (max 200 characters), might be CSV
    public let asset: String?
    // Depreciated: now an empty string
    public let type: StickerType
    public let format_type: StickerFormat
    public let available: Bool? // Whether this guild sticker can be used, may be false due to loss of Server Boosts
    public let guild_id: Snowflake?
    public let user: User? // User that uploaded sticker
    public let sort_value: Int? // Sticker's sort order in its pack
}

public struct StickerItem: Codable, Identifiable, Hashable {
    public init(id: Snowflake, name: String, format_type: StickerFormat) {
        self.id = id
        self.name = name
        self.format_type = format_type
    }

    public let id: Snowflake
    public let name: String
    public let format_type: StickerFormat
}

public struct StickerPack: Codable, GatewayData, Identifiable {
    public let id: Snowflake
    public let stickers: [Sticker]
    public let name: String
    public let sku_id: Snowflake
    public let cover_sticker_id: Snowflake?
    public let description: String
    public let banner_asset_id: HashedAsset<StickerPackBanner>?
}
