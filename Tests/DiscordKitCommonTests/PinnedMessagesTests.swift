//
//  PinnedMessagesTests.swift
//  DiscordKitTests
//
//  Created by Vincent on 18/8/26.
//

import XCTest
@testable import DiscordKitCore

final class PinnedMessagesTests: XCTestCase {
    func testPageDecodingPreservesPinTimestampAndMessage() throws {
        let page = try DiscordREST.decoder.decode(PinnedMessagesPage.self, from: Data("""
        {
          "items": [{
            "pinned_at": "2026-08-18T01:02:03.456Z",
            "message": {
              "id": "1001",
              "channel_id": "2001",
              "author": {
                "id": "3001",
                "username": "alice",
                "discriminator": "0",
                "public_flags": 0
              },
              "content": "Pinned",
              "timestamp": "2026-08-17T12:00:00.000Z",
              "tts": false,
              "mention_everyone": false,
              "mentions": [],
              "mention_roles": [],
              "attachments": [],
              "embeds": [],
              "pinned": true,
              "type": 0
            }
          }],
          "has_more": true
        }
        """.utf8))

        XCTAssertTrue(page.hasMore)
        XCTAssertEqual(page.items.count, 1)
        XCTAssertEqual(page.items[0].message.id, "1001")
        XCTAssertEqual(page.items[0].message.content, "Pinned")
        XCTAssertEqual(
            page.items[0].pinnedAt,
            try XCTUnwrap(ISO8601DateFormatter.pinnedMessagesTest.date(from: "2026-08-18T01:02:03.456Z"))
        )
    }

    func testFirstPageQueryOmitsBefore() {
        XCTAssertEqual(
            PinnedMessagesQuery(limit: 25, before: nil).queryItems(),
            [URLQueryItem(name: "limit", value: "25")]
        )
    }

    func testNextPageQueryUsesISO8601Cursor() throws {
        let before = try XCTUnwrap(
            ISO8601DateFormatter.pinnedMessagesTest.date(from: "2026-08-18T01:02:03.456Z")
        )
        XCTAssertEqual(
            PinnedMessagesQuery(limit: 10, before: before).queryItems(),
            [
                URLQueryItem(name: "limit", value: "10"),
                URLQueryItem(name: "before", value: "2026-08-18T01:02:03.456Z")
            ]
        )
    }
}

private extension ISO8601DateFormatter {
    static let pinnedMessagesTest: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
