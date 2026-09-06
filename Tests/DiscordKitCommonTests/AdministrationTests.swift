//
//  AdministrationTests.swift
//  DiscordKitCommonTests
//
//  Created by Vincent on 7/9/26.
//

import XCTest
import DiscordKitCore

final class AdministrationTests: XCTestCase {
    func testGuestFlagDecodesFromWireInteger() throws {
        let flags = try JSONDecoder().decode(Member.Flags.self, from: Data("16".utf8))
        XCTAssertTrue(flags.contains(.isGuest))
    }

    func testStickerMultipartUsesSeparateFieldsAndNamedFile() {
        let body = DiscordREST.guildStickerMultipartBody(
            boundary: "test-boundary", name: "Wave", description: "Hello", tags: "wave",
            file: Data([0, 1, 2]), filename: "wave.png", mimeType: "image/png"
        )
        let text = String(decoding: body, as: UTF8.self)
        XCTAssertTrue(text.contains("name=\"name\"\r\n\r\nWave\r\n"))
        XCTAssertTrue(text.contains("name=\"tags\"\r\n\r\nwave\r\n"))
        XCTAssertTrue(text.contains("name=\"description\"\r\n\r\nHello\r\n"))
        XCTAssertTrue(text.contains("name=\"file\"; filename=\"wave.png\"\r\nContent-Type: image/png\r\n"))
        XCTAssertFalse(text.contains("payload_json"))
        XCTAssertFalse(text.contains("files[0]"))
        XCTAssertTrue(body.range(of: Data([0, 1, 2])) != nil)
        XCTAssertTrue(text.hasSuffix("\r\n--test-boundary--\r\n"))
    }

    func testOverwriteUsesStringBitfieldsWithoutLosingModernPermissions() throws {
        let overwrite = PermOverwrite(id: "1", type: .role, allow: [.bypassSlowmode, .useSoundboard], deny: .useExternalSounds)
        let body = try JSONEncoder().encode(overwrite)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
        XCTAssertEqual(object["allow"] as? String, String((UInt64(1) << 52) | (UInt64(1) << 42)))
        XCTAssertEqual(object["type"] as? Int, 0)
        XCTAssertEqual(try JSONDecoder().decode(PermOverwrite.self, from: body), overwrite)
    }
}
