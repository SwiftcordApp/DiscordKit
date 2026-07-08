//
//  MessageTypeTests.swift
//
//
//  Created by Vincent on 8/7/26.
//

import XCTest
import DiscordKitCore

final class MessageTypeTests: XCTestCase {
    func testRegularMessageTypes() {
        XCTAssertTrue(MessageType.defaultMsg.isRegular)
        XCTAssertTrue(MessageType.reply.isRegular)
        XCTAssertTrue(MessageType.chatInputCmd.isRegular)
        XCTAssertTrue(MessageType.contextMenuCmd.isRegular)
    }

    func testSystemMessageTypes() {
        XCTAssertFalse(MessageType.recipientAdd.isRegular)
        XCTAssertFalse(MessageType.call.isRegular)
        XCTAssertFalse(MessageType.guildMemberJoin.isRegular)
        XCTAssertFalse(MessageType.userPremiumGuildSub.isRegular)
        XCTAssertFalse(MessageType.autoModAct.isRegular)
    }
}
