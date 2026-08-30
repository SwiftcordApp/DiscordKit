//
//  RequestErrorTests.swift
//  DiscordKit
//
//  Created by Vincent on 31/8/26.
//

import DiscordKitCore
import Foundation
import XCTest

final class RequestErrorTests: XCTestCase {
    func testDiscordResponseMessageIsPresentedToTheUser() {
        let error = DiscordREST.RequestError.apiError(
            statusCode: 400,
            discordCode: 50_035,
            message: "Invalid Form Body",
            retryAfter: nil
        )

        XCTAssertEqual(error.localizedDescription, "Invalid Form Body.")
        XCTAssertEqual(error.failureReason, "Discord error code 50035.")
    }

    func testPermissionAndServerFailuresUseFriendlyDescriptions() {
        XCTAssertEqual(
            DiscordREST.RequestError.apiError(
                statusCode: 403,
                discordCode: 50_013,
                message: "Missing Permissions",
                retryAfter: nil
            ).localizedDescription,
            "You don't have permission to perform this action."
        )
        XCTAssertEqual(
            DiscordREST.RequestError.unexpectedResponseCode(502).localizedDescription,
            "Discord is having trouble completing requests right now. Try again later."
        )
    }

    func testRateLimitIncludesRetryDelay() {
        let error = DiscordREST.RequestError.apiError(
            statusCode: 429,
            discordCode: nil,
            message: "You are being rate limited.",
            retryAfter: 1.2
        )

        XCTAssertEqual(
            error.localizedDescription,
            "You're doing that too quickly. Try again in 2 seconds."
        )
    }

    func testNetworkAndDecodingFailuresUseFriendlyDescriptions() {
        XCTAssertEqual(
            DiscordREST.RequestError.networkError(
                error: URLError(.notConnectedToInternet)
            ).localizedDescription,
            "You're offline. Check your internet connection and try again."
        )
        XCTAssertEqual(
            DiscordREST.RequestError.jsonDecodingError(
                error: DecodingError.dataCorrupted(
                    .init(codingPath: [], debugDescription: "Invalid JSON")
                )
            ).localizedDescription,
            "Discord returned data the app couldn't understand."
        )
    }

    func testGenericReasonIsPreserved() {
        XCTAssertEqual(
            DiscordREST.RequestError.genericError(reason: "The request failed validation").localizedDescription,
            "The request failed validation"
        )
    }

    func testAttachmentUploadErrorsUseFriendlyDescriptions() {
        XCTAssertEqual(
            AttachmentUploadError.invalidUploadURL("not a URL").localizedDescription,
            "Discord returned an invalid attachment upload URL."
        )
        XCTAssertEqual(
            AttachmentUploadError.invalidUploadResponse.localizedDescription,
            "Discord returned an invalid response while uploading the attachment."
        )
        XCTAssertEqual(
            AttachmentUploadError.unexpectedResponseCode(413).localizedDescription,
            "Discord couldn't upload the attachment (HTTP 413)."
        )
    }
}
