//
//  MessageSnapshotTests.swift
//  DiscordKitTests
//
//  Created by Vincent on 31/7/26.
//

import DiscordKitCore
import XCTest

final class MessageSnapshotTests: XCTestCase {
    func testForwardMessageDecodesSnapshotPayload() throws {
        let message = try DiscordREST.decoder.decode(Message.self, from: Data(Self.forwardPayload.utf8))

        XCTAssertEqual(message.message_reference?.type, .forward)
        XCTAssertEqual(message.message_reference?.guild_id, "source-guild")
        XCTAssertEqual(message.message_snapshots?.count, 1)

        let snapshot = try XCTUnwrap(message.message_snapshots?.first?.message)
        XCTAssertEqual(snapshot.type, .defaultMsg)
        XCTAssertEqual(snapshot.content, "Forwarded <@mentioned>")
        XCTAssertEqual(snapshot.attachments.map(\.id), ["attachment"])
        XCTAssertEqual(snapshot.embeds.first?.description, "embed")
        XCTAssertEqual(snapshot.mentions.map(\.id), ["mentioned"])
        XCTAssertEqual(snapshot.mention_roles, ["role"])
        XCTAssertEqual(snapshot.components.count, 1)
        XCTAssertFalse(snapshot.sourceMessageDeleted)
    }

    func testSnapshotDefaultsMissingFieldsAndSkipsUnknownComponents() throws {
        let snapshot = try DiscordREST.decoder.decode(SnapshotMessage.self, from: Data("""
        {
          "type": 999,
          "timestamp": "2026-07-30T12:00:00Z",
          "components": [{ "type": 999 }]
        }
        """.utf8))

        XCTAssertEqual(snapshot.type, .defaultMsg)
        XCTAssertEqual(snapshot.content, "")
        XCTAssertEqual(snapshot.flags, 0)
        XCTAssertTrue(snapshot.attachments.isEmpty)
        XCTAssertTrue(snapshot.embeds.isEmpty)
        XCTAssertTrue(snapshot.mentions.isEmpty)
        XCTAssertTrue(snapshot.components.isEmpty)
    }

    func testReferenceTypeDefaultsAndToleratesUnknownValues() throws {
        let legacy = try JSONDecoder().decode(MessageReference.self, from: Data("""
        { "message_id": "message" }
        """.utf8))
        let unknown = try JSONDecoder().decode(MessageReference.self, from: Data("""
        { "message_id": "message", "type": 999 }
        """.utf8))

        XCTAssertNil(legacy.type)
        XCTAssertEqual(unknown.type, .unknown)
    }

    func testSourceMessageDeletedFlag() {
        let snapshot = SnapshotMessage(
            timestamp: Date(timeIntervalSince1970: 0),
            flags: 1 << 3
        )

        XCTAssertTrue(snapshot.sourceMessageDeleted)
    }

    func testRenderedSnapshotChangesMessageEqualityAndHashing() throws {
        let first = try Self.forwardMessage(snapshotContent: "first")
        let equalCopy = try Self.forwardMessage(snapshotContent: "first")
        let changed = try Self.forwardMessage(snapshotContent: "changed")

        XCTAssertEqual(first, equalCopy)
        XCTAssertEqual(first.hashValue, equalCopy.hashValue)
        XCTAssertNotEqual(first, changed)
    }

    private static func forwardMessage(snapshotContent: String) throws -> Message {
        let payload = forwardPayload.replacingOccurrences(
            of: "Forwarded <@mentioned>",
            with: snapshotContent
        )
        return try DiscordREST.decoder.decode(Message.self, from: Data(payload.utf8))
    }

    private static let forwardPayload = """
    {
      "id": "forward",
      "channel_id": "destination-channel",
      "guild_id": "destination-guild",
      "author": {
        "id": "forwarder",
        "username": "Forwarder",
        "discriminator": "0"
      },
      "content": "",
      "timestamp": "2026-07-30T12:01:00Z",
      "tts": false,
      "mention_everyone": false,
      "mentions": [],
      "mention_roles": [],
      "attachments": [],
      "embeds": [],
      "pinned": false,
      "type": 0,
      "flags": 16384,
      "message_reference": {
        "type": 1,
        "message_id": "source-message",
        "channel_id": "source-channel",
        "guild_id": "source-guild"
      },
      "message_snapshots": [{
        "message": {
          "type": 0,
          "content": "Forwarded <@mentioned>",
          "timestamp": "2026-07-30T12:00:00Z",
          "edited_timestamp": null,
          "attachments": [{
            "id": "attachment",
            "filename": "image.png",
            "content_type": "image/png",
            "size": 10,
            "url": "https://cdn.example/image.png",
            "proxy_url": "https://proxy.example/image.png",
            "width": 100,
            "height": 100
          }],
          "embeds": [{ "type": "rich", "description": "embed" }],
          "flags": 0,
          "mentions": [{
            "id": "mentioned",
            "username": "Mentioned",
            "discriminator": "0"
          }],
          "mention_roles": ["role"],
          "components": [{ "type": 2 }, { "type": 999 }]
        }
      }]
    }
    """
}
