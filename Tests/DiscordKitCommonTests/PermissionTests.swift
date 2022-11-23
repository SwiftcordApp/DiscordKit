//
//  PermissionTests.swift
//  
//
//  Created by Charlene Campbell on 5/30/22.
//

import XCTest
import DiscordKitCore

class PermissionTests: XCTestCase {
    func testPermissionsDecode() {
        XCTAssertEqual(
            Permissions([.viewChannel, .addReactions, .banMembers]),
            try JSONDecoder().decode(Permissions.self, from: "\"1092\"".data(using: .utf8)!)
        )
        XCTAssertEqual(
            Permissions([]),
            try JSONDecoder().decode(Permissions.self, from: "\"\"".data(using: .utf8)!)
        )
        XCTAssertThrowsError(
            try JSONDecoder().decode(Permissions.self, from: "1092".data(using: .utf8)!)
        )
    }

    func testPermissionsEncode() {
        XCTAssertEqual(
            "\"3072\"",
            String(data: try JSONEncoder().encode(Permissions([.viewChannel, .sendMessages])), encoding: .utf8)
        )
    }
}
