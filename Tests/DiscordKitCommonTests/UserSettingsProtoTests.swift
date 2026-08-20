//
//  UserSettingsProtoTests.swift
//  DiscordKitCommonTests
//
//  Created by Vincent on 5/8/26.
//

import XCTest
@testable import DiscordKitCore

final class UserSettingsProtoTests: XCTestCase {
    func testResponseDecodesSettings() throws {
        let response = try DiscordREST.decoder.decode(
            UserSettingsProtoResponse.self,
            from: Data(#"{"settings":"AQID","out_of_date":true}"#.utf8)
        )

        XCTAssertEqual(response.settings, "AQID")
        XCTAssertEqual(response.decodedSettings, Data([1, 2, 3]))
    }

    func testSettingsDecoderAcceptsURLSafeUnpaddedBase64() {
        XCTAssertEqual(
            Data(base64URL: "-_8"),
            Data([251, 255])
        )
    }

    func testPatchRequestUsesDiscordWireKeys() throws {
        let encoded = try DiscordREST.encoder.encode(UserSettingsProtoUpdateRequest(
            settings: "AQID",
            requiredDataVersion: 42
        ))
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )

        XCTAssertEqual(object["settings"] as? String, "AQID")
        XCTAssertEqual(object["required_data_version"] as? Int, 42)
    }

    func testPatchRequestOmitsAbsentDataVersion() throws {
        let encoded = try DiscordREST.encoder.encode(UserSettingsProtoUpdateRequest(
            settings: "AQID",
            requiredDataVersion: nil
        ))
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )

        XCTAssertEqual(Set(object.keys), ["settings"])
    }

    func testInvalidSettingsErrorCodeIsNumeric() throws {
        let error = try DiscordREST.decoder.decode(
            UserSettingsProtoErrorResponse.self,
            from: Data(#"{"code":50105}"#.utf8)
        )

        XCTAssertEqual(error.code, 50_105)
    }
}
