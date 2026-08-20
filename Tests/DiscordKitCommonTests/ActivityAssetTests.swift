//
//  ActivityAssetTests.swift
//  DiscordKitCommonTests
//
//  Created by Vincent on 9/8/26.
//

import Foundation
import XCTest
@testable import DiscordKitCore

final class ActivityAssetTests: XCTestCase {
    func testSpotifyAssetURL() throws {
        let resource = try XCTUnwrap(activity().assetResource(for: "spotify:album image", size: 128))

        XCTAssertEqual(resource.url.absoluteString, "https://i.scdn.co/image/album%20image")
        XCTAssertFalse(resource.isAnimated)
    }

    func testTwitchAssetURL() throws {
        let resource = try XCTUnwrap(activity().assetResource(for: "twitch:creator", size: 160))

        XCTAssertEqual(
            resource.url.absoluteString,
            "https://static-cdn.jtvnw.net/previews-ttv/live_user_creator-160x160.jpg"
        )
    }

    func testYouTubeAssetURL() throws {
        let resource = try XCTUnwrap(activity().assetResource(for: "youtube:video-id", size: 128))

        XCTAssertEqual(resource.url.absoluteString, "https://i.ytimg.com/vi/video-id/hqdefault_live.jpg")
    }

    func testMediaProxyAnimatedAssetURL() throws {
        let resource = try XCTUnwrap(
            activity().assetResource(for: "mp:external/example.gif", size: 128)
        )
        let components = try XCTUnwrap(URLComponents(url: resource.url, resolvingAgainstBaseURL: false))

        XCTAssertEqual(components.scheme, "https")
        XCTAssertEqual(components.host, "media.discordapp.net")
        XCTAssertEqual(components.path, "/external/example.gif")
        XCTAssertEqual(
            Set(components.queryItems ?? []),
            Set([
                URLQueryItem(name: "width", value: "128"),
                URLQueryItem(name: "height", value: "128"),
                URLQueryItem(name: "format", value: "webp"),
                URLQueryItem(name: "animated", value: "true")
            ])
        )
        XCTAssertTrue(resource.isAnimated)
    }

    func testApplicationAssetURL() throws {
        let resource = try XCTUnwrap(
            activity(applicationID: "application").assetResource(for: "asset", size: 256)
        )

        XCTAssertEqual(
            resource.url.absoluteString,
            "https://cdn.discordapp.com/app-assets/application/asset.png?size=256"
        )
        XCTAssertFalse(resource.isAnimated)
    }

    func testApplicationAssetRequiresApplicationID() {
        XCTAssertNil(activity().assetResource(for: "asset", size: 128))
    }

    private func activity(applicationID: Snowflake? = nil) -> Activity {
        Activity(name: "Activity", type: .game, application_id: applicationID)
    }
}
