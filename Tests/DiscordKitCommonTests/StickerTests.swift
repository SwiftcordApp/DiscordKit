//
//  StickerTests.swift
//  DiscordKitTests
//
//  Created by Vincent on 7/9/26.
//

import DiscordKitCore
import XCTest

final class StickerTests: XCTestCase {
    func testStandardPackPreservesFullStickerMetadataForSending() throws {
        let pack = try DiscordREST.decoder.decode(StickerPack.self, from: Data("""
        {"id":"pack","name":"Wumpus","sku_id":"sku","description":"Hello","stickers":[
          {"id":"sticker","pack_id":"pack","name":"Wave","description":"A wave","tags":"hello,wave",
           "type":1,"format_type":3}
        ]}
        """.utf8))
        let sticker = try XCTUnwrap(pack.stickers.first)
        XCTAssertEqual(sticker.pack_id, "pack")
        XCTAssertEqual(sticker.type, .standard)
        XCTAssertEqual(sticker.tags, "hello,wave")
        XCTAssertEqual(sticker.item.format_type, .lottie)
    }

    func testStickerOnlyMessageEncodesIDWithoutAttachment() throws {
        let message = NewMessage(content: "", sticker_ids: ["123"])
        let data = try JSONEncoder().encode(message)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(json["sticker_ids"] as? [String], ["123"])
        XCTAssertEqual(json["content"] as? String, "")
        XCTAssertNil(json["attachments"])
    }

    func testRoleSubscriptionFlagsDecodeDiscordNullPresence() throws {
        let tags = try JSONDecoder().decode(RoleTags.self, from: Data("""
        {"subscription_listing_id":"123","available_for_purchase":null,"premium_subscriber":null}
        """.utf8))
        XCTAssertEqual(tags.subscription_listing_id, "123")
        XCTAssertTrue(tags.available_for_purchase)
        XCTAssertEqual(tags.premium_subscriber, true)
        let ordinary = try JSONDecoder().decode(RoleTags.self, from: Data("{}".utf8))
        XCTAssertFalse(ordinary.available_for_purchase)
        XCTAssertNil(ordinary.subscription_listing_id)
    }

    func testStickerUpdateDispatchAndLegacySnapshotFallback() throws {
        let incoming = try DiscordREST.decoder.decode(GatewayIncoming.self, from: Data("""
        {"op":0,"s":1,"t":"GUILD_STICKERS_UPDATE","d":{"guild_id":"guild","stickers":[
          {"id":"123","name":"Wave","tags":"wave","type":2,"format_type":2,"guild_id":"guild","available":true}
        ]}}
        """.utf8))
        guard case .guildStickersUpdate(let update) = incoming.data else {
            return XCTFail("Expected typed sticker update")
        }
        XCTAssertEqual(update.guild_id, "guild")
        let sticker = try XCTUnwrap(update.stickers.first)
        let legacy = SnapshotMessage(timestamp: Date(), stickers: [sticker])
        XCTAssertEqual(legacy.stickerItems, [sticker.item])
        let modern = StickerItem(id: "456", name: "Modern", format_type: .gif)
        let both = SnapshotMessage(timestamp: Date(), stickers: [sticker], sticker_items: [modern])
        XCTAssertEqual(both.stickerItems, [modern])
    }

}
