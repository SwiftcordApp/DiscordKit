//
//  MessageEqualityTests.swift
//  DiscordKit
//
//  Created by Vincent on 21/7/26.
//

import DiscordKitCore
import XCTest

final class MessageEqualityTests: XCTestCase {
    func testCallEndChangesMessageEquality() throws {
        let active = try callMessage(endedTimestamp: nil)
        let ended = try callMessage(endedTimestamp: "2026-07-08T03:17:21.769000+00:00")

        XCTAssertNotEqual(active, ended)
    }
}

private func callMessage(endedTimestamp: String?) throws -> Message {
    let endedTimestampJSON = endedTimestamp.map { #""\#($0)""# } ?? "null"
    return try DiscordREST.decoder.decode(Message.self, from: Data("""
    {
      "id": "message",
      "channel_id": "channel",
      "author": {
        "id": "author",
        "username": "Caller",
        "discriminator": "0"
      },
      "content": "",
      "timestamp": "2026-07-08T02:00:24.243000+00:00",
      "tts": false,
      "mention_everyone": false,
      "mentions": [],
      "mention_roles": [],
      "attachments": [],
      "embeds": [],
      "pinned": false,
      "type": 3,
      "call": {
        "participants": ["author"],
        "ended_timestamp": \(endedTimestampJSON)
      }
    }
    """.utf8))
}
