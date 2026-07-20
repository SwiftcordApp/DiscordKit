//
//  MessageSearchQueryTests.swift
//

import XCTest
@testable import DiscordKitCore

final class MessageSearchQueryTests: XCTestCase {
    private func encoded(_ query: MessageSearchQuery) -> String {
        var components = URLComponents()
        components.queryItems = query.queryItems()
        return components.percentEncodedQuery ?? ""
    }

    func testArraysEmitRepeatedKeysWithoutBrackets() {
        let query = MessageSearchQuery(
            content: "hello",
            authorIDs: ["111", "222"],
            has: ["image", "-video"]
        )
        XCTAssertEqual(
            encoded(query),
            "content=hello&author_id=111&author_id=222&has=image&has=-video"
                + "&sort_by=timestamp&sort_order=desc&offset=0"
        )
    }

    func testDefaultQueryOmitsEmptyFieldsAndLimit() {
        let items = MessageSearchQuery().queryItems()
        XCTAssertEqual(
            items.map(\.name),
            ["sort_by", "sort_order", "offset"]
        )
    }

    func testBooleanAndPolicyEncoding() {
        let query = MessageSearchQuery(
            pinned: [true, false],
            sortBy: .relevance,
            sortOrder: .asc,
            offset: 25,
            includeNSFW: true
        )
        XCTAssertEqual(
            encoded(query),
            "pinned=true&pinned=false&sort_by=relevance&sort_order=asc&offset=25&include_nsfw=true"
        )
    }

    func testAttemptsOnlyIncludedWhenSet() {
        var query = MessageSearchQuery(content: "x")
        XCTAssertFalse(encoded(query).contains("attempts"))
        query.attempts = 2
        XCTAssertTrue(encoded(query).hasSuffix("attempts=2"))
    }

    func testDateBoundsAndChannelFilters() {
        let query = MessageSearchQuery(
            minID: "100",
            maxID: "200",
            channelIDs: ["333"],
            authorTypes: ["-bot"]
        )
        XCTAssertEqual(
            encoded(query),
            "min_id=100&max_id=200&channel_id=333&author_type=-bot"
                + "&sort_by=timestamp&sort_order=desc&offset=0"
        )
    }

    func testHasFilters() {
        XCTAssertFalse(MessageSearchQuery().hasFilters)
        XCTAssertFalse(MessageSearchQuery(content: "").hasFilters)
        XCTAssertTrue(MessageSearchQuery(content: "hi").hasFilters)
        XCTAssertTrue(MessageSearchQuery(minID: "1").hasFilters)
        XCTAssertTrue(MessageSearchQuery(pinned: [false]).hasFilters)
    }

    func testSearchResultsDecoding() throws {
        let json = Data("""
        {
          "analytics_id": "abc123",
          "total_results": 2,
          "doing_deep_historical_index": true,
          "documents_indexed": 512,
          "messages": [
            [
              {
                "id": "1001",
                "channel_id": "2001",
                "author": {
                  "id": "3001",
                  "username": "alice",
                  "discriminator": "0",
                  "public_flags": 0
                },
                "content": "primary hit",
                "timestamp": "2026-07-01T12:00:00.000Z",
                "tts": false,
                "mention_everyone": false,
                "mentions": [],
                "mention_roles": [],
                "attachments": [],
                "embeds": [],
                "pinned": false,
                "type": 0
              },
              {"id": "broken group member"}
            ]
          ],
          "channels": [
            {"id": "2001", "type": 0, "name": "general"}
          ],
          "members": [
            {"id": "4001", "user_id": "3001", "flags": 0, "join_timestamp": "2026-07-01T12:00:00.000Z"}
          ]
        }
        """.utf8)

        let results = try DiscordREST.decoder.decode(MessageSearchResults.self, from: json)
        XCTAssertEqual(results.analytics_id, "abc123")
        XCTAssertEqual(results.total_results, 2)
        XCTAssertEqual(results.doing_deep_historical_index, true)
        XCTAssertEqual(results.documents_indexed, 512)
        XCTAssertNil(results.threads)

        XCTAssertEqual(results.messages.count, 1)
        let group = try XCTUnwrap(results.messages.first)
        let primary = try group.first?.unwrap()
        XCTAssertEqual(primary?.id, "1001")
        XCTAssertEqual(primary?.content, "primary hit")
        XCTAssertThrowsError(try group[1].unwrap(), "malformed group members degrade individually")

        XCTAssertEqual(try results.channels?.first?.unwrap().name, "general")
        XCTAssertEqual(results.members?.first?.user_id, "3001")
    }
}
