//
//  Embed.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

public enum EmbedType: String, Codable {
    case rich = "rich"   // Generic embed rendered from embed attributes
    case image = "image"
    case video = "video"
    case gifVid = "gifv" // GIF rendered as video
    case article = "article"
    case link = "link"
    case autoMod = "auto_moderation_message"
}

public struct Embed: Codable, Identifiable, Equatable, Hashable {
    public init(title: String? = nil, type: EmbedType? = nil, description: String? = nil, url: String? = nil, timestamp: Date? = nil, color: Int? = nil, footer: EmbedFooter? = nil, image: EmbedMedia? = nil, thumbnail: EmbedMedia? = nil, video: EmbedMedia? = nil, provider: EmbedProvider? = nil, author: EmbedAuthor? = nil, fields: [EmbedField]? = nil) {
        self.title = title
        self.type = type
        self.description = description
        self.url = url
        self.timestamp = timestamp
        self.color = color
        self.footer = footer
        self.image = image
        self.thumbnail = thumbnail
        self.video = video
        self.provider = provider
        self.author = author
        self.fields = fields
    }

    public var title: String?
    public let type: EmbedType?
    public var description: String?
    public var url: String?
    public var timestamp: Date?
    public var color: Int?
    public var footer: EmbedFooter?
    public let image: EmbedMedia?
    public let thumbnail: EmbedMedia?
    public let video: EmbedMedia?
    public let provider: EmbedProvider?
    public var author: EmbedAuthor?
    public var fields: [EmbedField]?

    public var id: String {
		"\(title ?? "")\(description ?? "")\(url ?? "")\(String(color ?? 0))\(String(timestamp?.timeIntervalSince1970 ?? 0))"
    }
}

public struct EmbedFooter: Codable, Equatable, Hashable {
    public init(text: String, icon_url: String? = nil, proxy_icon_url: String? = nil) {
        self.text = text
        self.icon_url = icon_url
        self.proxy_icon_url = proxy_icon_url
    }

    public let text: String
    public let icon_url: String?
    public let proxy_icon_url: String?
}

public struct EmbedMedia: Codable, Equatable, Hashable {
    public init(url: String, proxy_url: String? = nil, height: Int? = nil, width: Int? = nil) {
        self.url = url
        self.proxy_url = proxy_url
        self.height = height
        self.width = width
    }
    
    public let url: String
    public let proxy_url: String?
    public let height: Int?
    public let width: Int?
}

public struct EmbedProvider: Codable, Equatable, Hashable {
    public init(name: String?, url: String?) {
        self.name = name
        self.url = url
    }
    
    public let name: String?
    public let url: String?
}

public struct EmbedAuthor: Codable, Equatable, Hashable {
    public init(name: String, url: String?, icon_url: String?, proxy_icon_url: String?) {
        self.name = name
        self.url = url
        self.icon_url = icon_url
        self.proxy_icon_url = proxy_icon_url
    }
    
    public let name: String
    public let url: String?
    public let icon_url: String?
    public let proxy_icon_url: String?
}

public struct EmbedField: Codable, Identifiable, Equatable, Hashable {
    public let name: String
    public let value: String
    public let inline: Bool?
    public var id: String {
		name + value
    }
}
