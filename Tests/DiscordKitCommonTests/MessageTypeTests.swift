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

    func testMessageTypeDeletabilityMatchesDiscordPolicy() {
        let expectations: [(MessageType, Bool)] = [
            (.defaultMsg, true),
            (.recipientAdd, false),
            (.recipientRemove, false),
            (.call, false),
            (.chNameChange, false),
            (.chIconChange, false),
            (.chPinnedMsg, true),
            (.guildMemberJoin, true),
            (.userPremiumGuildSub, true),
            (.userPremiumGuildSubTier1, true),
            (.userPremiumGuildSubTier2, true),
            (.userPremiumGuildSubTier3, true),
            (.chFollowAdd, true),
            (.guildDiscoveryDisqualified, true),
            (.guildDiscoveryRequalified, true),
            (.guildDiscoveryGraceInitial, true),
            (.guildDiscoveryGraceFinal, true),
            (.threadCreated, true),
            (.reply, true),
            (.chatInputCmd, true),
            (.threadStarterMsg, false),
            (.guildInviteReminder, true),
            (.contextMenuCmd, true),
            (.autoModAct, true)
        ]

        for (messageType, expected) in expectations {
            XCTAssertEqual(
                messageType.isDeletable,
                expected,
                "Unexpected deletability for message type \(messageType.rawValue)"
            )
        }
    }

    func testMessageDeletionPermissions() {
        XCTAssertTrue(MessageType.defaultMsg.canDelete(isFromCurrentUser: true, canManageMessages: false))
        XCTAssertFalse(MessageType.defaultMsg.canDelete(isFromCurrentUser: false, canManageMessages: false))
        XCTAssertTrue(MessageType.defaultMsg.canDelete(isFromCurrentUser: false, canManageMessages: true))
        XCTAssertFalse(MessageType.call.canDelete(isFromCurrentUser: true, canManageMessages: true))
        XCTAssertFalse(MessageType.autoModAct.canDelete(isFromCurrentUser: true, canManageMessages: false))
        XCTAssertTrue(MessageType.autoModAct.canDelete(isFromCurrentUser: false, canManageMessages: true))
    }
}
