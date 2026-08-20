//
//  StreamPreviewTests.swift
//  DiscordKitCommonTests
//
//  Created by Zerui on 13/8/26.
//

import Foundation
import XCTest
@testable import DiscordKitCore

final class StreamPreviewTests: XCTestCase {
    func testPreviewResponseDecodesDiscordCDNURL() throws {
        let preview = try JSONDecoder().decode(
            StreamPreview.self,
            from: Data(#"{"url":"https://cdn.discordapp.com/streams/key/hash"}"#.utf8)
        )

        XCTAssertEqual(preview.url, "https://cdn.discordapp.com/streams/key/hash")
        XCTAssertEqual(preview.previewURL?.host, "cdn.discordapp.com")
    }

    func testMissingPreviewCanFallBackWithoutDecodeFailure() throws {
        let preview = try JSONDecoder().decode(
            StreamPreview.self,
            from: Data(#"{"url":null}"#.utf8)
        )

        XCTAssertNil(preview.previewURL)
    }
}
