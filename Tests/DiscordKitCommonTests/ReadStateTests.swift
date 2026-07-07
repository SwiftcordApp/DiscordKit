//
//  ReadStateTests.swift
//

import XCTest
@testable import DiscordKitCore

final class ReadStateTests: XCTestCase {
    func testModernReadStateEntryDecodesCurrentFieldsAndUnknownType() throws {
        let readState = try decodeReadState("""
        {
          "entries":[{
            "id":"channel",
            "read_state_type":7,
            "last_acked_id":"111",
            "mention_count":3,
            "badge_count":9,
            "flags":4,
            "last_viewed":4199,
            "last_pin_timestamp":"2026-06-29T10:11:12.000Z"
          }],
          "partial":true,
          "version":12
        }
        """)

        let entry = try XCTUnwrap(readState.entries.first)
        XCTAssertEqual(readState.partial, true)
        XCTAssertEqual(readState.version, 12)
        XCTAssertEqual(entry.id, "channel")
        XCTAssertEqual(entry.read_state_type, .unknown(7))
        XCTAssertEqual(entry.ackMessageID, "111")
        XCTAssertEqual(entry.mention_count, 3)
        XCTAssertEqual(entry.badge_count, 9)
        // Non-channel read states carry their count in badge_count
        XCTAssertEqual(entry.effectiveMentionCount, 9)
        XCTAssertEqual(entry.flags, 4)
        XCTAssertTrue(entry.hasLowImportanceMention)
        XCTAssertEqual(entry.last_viewed, 4199)
        XCTAssertNotNil(entry.last_pin_timestamp)
    }

    func testLegacyReadStateEntryDefaultsAndUsesLastMessageIDAsAck() throws {
        let readState = try decodeReadState("""
        {
          "entries":[{
            "id":"channel",
            "last_message_id":222,
            "mention_count":0
          }]
        }
        """)

        let entry = try XCTUnwrap(readState.entries.first)
        XCTAssertFalse(readState.partial)
        XCTAssertEqual(readState.version, 0)
        XCTAssertEqual(entry.read_state_type, .channel)
        XCTAssertEqual(entry.ackMessageID, "222")
        XCTAssertEqual(entry.effectiveMentionCount, 0)
    }

    func testReadStateEntryDecodesLooseDiscordDateFormats() throws {
        let readState = try decodeReadState("""
        {
          "entries":[{
            "id":"channel",
            "last_pin_timestamp":"1782814272"
          }]
        }
        """)

        let entry = try XCTUnwrap(readState.entries.first)
        XCTAssertEqual(try XCTUnwrap(entry.last_pin_timestamp).timeIntervalSince1970, 1_782_814_272, accuracy: 0.001)
    }

    func testMessageACKDecodesManualMarkUnread() throws {
        let ack = try DiscordREST.decoder.decode(MessageACKEvt.self, from: Data("""
        {
          "channel_id":"channel",
          "message_id":"111",
          "version":3,
          "manual":true,
          "mention_count":2
        }
        """.utf8))

        XCTAssertEqual(ack.manual, true)
        XCTAssertEqual(ack.mention_count, 2)
    }

    func testReadStateTypeMapsKnownRawValues() {
        XCTAssertEqual(ReadStateType(rawValue: 1), .guildEvent)
        XCTAssertEqual(ReadStateType(rawValue: 5), .messageRequests)
        XCTAssertEqual(ReadStateType(rawValue: 9).rawValue, 9)
    }

    func testSnowflakeIsNewerComparesNumerically() {
        XCTAssertTrue("10000000000000000000".isNewer(than: "9999999999999999999"))
        XCTAssertTrue("2".isNewer(than: nil))
        XCTAssertFalse("100".isNewer(than: "100"))
    }

    func testDiscordDateDecoderDecodesNumericTimestamp() throws {
        let date = try DiscordREST.decoder.decode(Date.self, from: Data("1782814272000".utf8))

        XCTAssertEqual(date.timeIntervalSince1970, 1_782_814_272, accuracy: 0.001)
    }

    func testChannelUnreadUpdateDispatchDecodes() throws {
        let incoming = try decodeGatewayIncoming("""
        {
          "op":0,
          "s":9,
          "t":"CHANNEL_UNREAD_UPDATE",
          "d":{
            "guild_id":"guild",
            "channel_unread_updates":[{
              "id":"channel",
              "last_message_id":"333"
            }]
          }
        }
        """)

        XCTAssertEqual(incoming.type, .channelUnreadUpdate)
        guard case .channelUnreadUpdate(let update) = incoming.data else {
            XCTFail("Expected channel unread update, got \(incoming.data)")
            return
        }

        XCTAssertEqual(update.guild_id, "guild")
        XCTAssertEqual(update.channel_unread_updates.first?.id, "channel")
        XCTAssertEqual(update.channel_unread_updates.first?.last_message_id, "333")
    }

    func testMessageReadAckEncodesOptionalFields() throws {
        let object = try encodeObject(MessageReadAckBody(
            token: "ack-token",
            last_viewed: 4096,
            flags: 1
        ))

        XCTAssertEqual(object["token"] as? String, "ack-token")
        XCTAssertEqual(object["flags"] as? Int, 1)
        XCTAssertEqual(object["last_viewed"] as? Int, 4096)
    }

    private func decodeReadState(_ json: String) throws -> ReadState {
        try DiscordREST.decoder.decode(ReadState.self, from: Data(json.utf8))
    }

    private func decodeGatewayIncoming(_ json: String) throws -> GatewayIncoming {
        try DiscordREST.decoder.decode(GatewayIncoming.self, from: Data(json.utf8))
    }

    private func encodeObject<T: Encodable>(_ value: T) throws -> [String: Any] {
        let data = try DiscordREST.encoder.encode(value)
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }
}
