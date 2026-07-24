//
//  GIFPickerTests.swift
//  DiscordKitCommonTests
//
//  Created by Vincent on 24/7/26.
//

import XCTest
@testable import DiscordKitCore

final class GIFPickerTests: XCTestCase {
    func testSearchQueryIncludesProviderQueryFormatAndLocaleButOmitsLimit() {
        let query = GIFPickerQuery(
            provider: .klipy,
            locale: .englishUS,
            mediaFormat: .mp4,
            query: "party time"
        )

        XCTAssertEqual(
            query.queryItems(),
            [
                URLQueryItem(name: "provider", value: "klipy"),
                URLQueryItem(name: "q", value: "party time"),
                URLQueryItem(name: "media_format", value: "mp4"),
                URLQueryItem(name: "locale", value: "en-US")
            ]
        )
    }

    func testSuggestionQueryOmitsMediaFormatAndIncludesLimit() {
        let query = GIFPickerQuery(
            provider: .klipy,
            locale: .englishGB,
            query: "party",
            limit: 5
        )

        XCTAssertEqual(
            query.queryItems(),
            [
                URLQueryItem(name: "provider", value: "klipy"),
                URLQueryItem(name: "q", value: "party"),
                URLQueryItem(name: "locale", value: "en-GB"),
                URLQueryItem(name: "limit", value: "5")
            ]
        )
    }

    func testResultDecodingPreservesCanonicalURL() throws {
        let result = try DiscordREST.decoder.decode(GIFPickerResult.self, from: Data("""
        {
          "width": 320,
          "height": 180,
          "src": "//static.klipy.com/preview.mp4",
          "gif_src": "https://static.klipy.com/fallback.gif",
          "url": "https://klipy.com/gifs/canonical-share-url",
          "id": "result-id",
          "ignored": "field"
        }
        """.utf8))

        XCTAssertEqual(result.width, 320)
        XCTAssertEqual(result.height, 180)
        XCTAssertEqual(result.src, "//static.klipy.com/preview.mp4")
        XCTAssertEqual(result.gifSrc, "https://static.klipy.com/fallback.gif")
        XCTAssertEqual(result.url, "https://klipy.com/gifs/canonical-share-url")
        XCTAssertEqual(result.id, "result-id")
    }

    func testTrendingResponseDecoding() throws {
        let response = try DiscordREST.decoder.decode(GIFTrendingResponse.self, from: Data("""
        {
          "categories": [
            {"name": "Celebrate", "src": "//static.klipy.com/category.mp4", "ignored": true}
          ],
          "gifs": [
            {"src": "https://static.klipy.com/trending.mp4", "ignored": true}
          ]
        }
        """.utf8))

        XCTAssertEqual(response.categories, [
            GIFTrendingCategory(name: "Celebrate", src: "//static.klipy.com/category.mp4")
        ])
        XCTAssertEqual(response.gifs, [
            GIFTrendingPreview(src: "https://static.klipy.com/trending.mp4")
        ])
    }

    func testSelectionRequestUsesDiscordWireKeys() throws {
        let encoded = try DiscordREST.encoder.encode(GIFSelectionRequest(
            id: "result-id",
            query: "party",
            provider: .klipy
        ))
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String : String])

        XCTAssertEqual(object, [
            "id": "result-id",
            "q": "party",
            "provider": "klipy"
        ])
    }
}
