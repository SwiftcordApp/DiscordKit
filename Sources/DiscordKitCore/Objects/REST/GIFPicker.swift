//
//  GIFPicker.swift
//  DiscordKit
//
//  Created by Vincent on 24/7/26.
//

import Foundation

public enum GIFProvider: String, Codable, CaseIterable {
    case tenor
    case giphy
    case klipy
}

public enum GIFMediaFormat: String, Codable {
    case mp4
    case webm
}

public struct GIFPickerResult: Decodable, Equatable {
    public let width: Int
    public let height: Int
    public let src: String
    public let gifSrc: String
    public let url: String
    public let id: String?

    public init(
        width: Int,
        height: Int,
        src: String,
        gifSrc: String,
        url: String,
        id: String? = nil
    ) {
        self.width = width
        self.height = height
        self.src = src
        self.gifSrc = gifSrc
        self.url = url
        self.id = id
    }

    private enum CodingKeys: String, CodingKey {
        case width
        case height
        case src
        case gifSrc = "gif_src"
        case url
        case id
    }
}

public struct GIFTrendingCategory: Decodable, Equatable {
    public let name: String
    public let src: String

    public init(name: String, src: String) {
        self.name = name
        self.src = src
    }
}

public struct GIFTrendingPreview: Decodable, Equatable {
    public let src: String

    public init(src: String) {
        self.src = src
    }
}

public struct GIFTrendingResponse: Decodable, Equatable {
    public let categories: [GIFTrendingCategory]
    public let gifs: [GIFTrendingPreview]

    public init(categories: [GIFTrendingCategory], gifs: [GIFTrendingPreview]) {
        self.categories = categories
        self.gifs = gifs
    }
}

struct GIFPickerQuery: Equatable {
    let provider: GIFProvider
    let locale: Locale
    let mediaFormat: GIFMediaFormat?
    let query: String?
    let limit: Int?

    init(
        provider: GIFProvider,
        locale: Locale,
        mediaFormat: GIFMediaFormat? = nil,
        query: String? = nil,
        limit: Int? = nil
    ) {
        self.provider = provider
        self.locale = locale
        self.mediaFormat = mediaFormat
        self.query = query
        self.limit = limit
    }

    func queryItems() -> [URLQueryItem] {
        var items = [URLQueryItem(name: "provider", value: provider.rawValue)]
        if let query {
            items.append(URLQueryItem(name: "q", value: query))
        }
        if let mediaFormat {
            items.append(URLQueryItem(name: "media_format", value: mediaFormat.rawValue))
        }
        items.append(URLQueryItem(name: "locale", value: locale.rawValue))
        if let limit {
            items.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        return items
    }
}

struct GIFSelectionRequest: Encodable, Equatable {
    let id: String
    let query: String
    let provider: GIFProvider

    private enum CodingKeys: String, CodingKey {
        case id
        case query = "q"
        case provider
    }
}
