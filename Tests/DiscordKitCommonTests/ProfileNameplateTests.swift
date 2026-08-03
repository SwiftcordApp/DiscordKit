//
//  ProfileNameplateTests.swift
//
//  Created by Vincent on 10/7/26.
//

import XCTest
@testable import DiscordKitCore

final class ProfileNameplateTests: XCTestCase {
    func testUserDecodesCompactNameplateWithCamelKeys() throws {
        let user = try DiscordREST.decoder.decode(User.self, from: Data("""
        {
          "id": "1",
          "username": "user",
          "discriminator": "0",
          "collectibles": {
            "nameplate": {
              "skuId": "123",
              "label": "Sky Plate",
              "palette": "Sky",
              "asset": "nameplate_asset",
              "expiresAt": 1770000000
            }
          }
        }
        """.utf8))

        let nameplate = try XCTUnwrap(user.collectibles?.nameplate)
        XCTAssertEqual(nameplate.sku_id, "123")
        XCTAssertEqual(nameplate.label, "Sky Plate")
        XCTAssertEqual(nameplate.palette, "Sky")
        XCTAssertEqual(nameplate.asset, "nameplate_asset")
        XCTAssertEqual(nameplate.expires_at, 1_770_000_000)
    }

    func testMemberDecodesCompactNameplateWithSnakeKeys() throws {
        let member = try DiscordREST.decoder.decode(Member.self, from: Data("""
        {
          "user": {
            "id": "1",
            "username": "user",
            "discriminator": "0"
          },
          "roles": [],
          "joined_at": "2026-07-10T00:00:00.000000+00:00",
          "deaf": false,
          "mute": false,
          "collectibles": {
            "nameplate": {
              "sku_id": "456",
              "label": "Crimson Plate",
              "palette": "Crimson",
              "expires_at": 1780000000
            }
          }
        }
        """.utf8))

        let nameplate = try XCTUnwrap(member.collectibles?.nameplate)
        XCTAssertEqual(nameplate.sku_id, "456")
        XCTAssertEqual(nameplate.label, "Crimson Plate")
        XCTAssertEqual(nameplate.palette, "Crimson")
        XCTAssertEqual(nameplate.expires_at, 1_780_000_000)
    }

    func testCurrentUserAndGuildMemberUpdateDecodeCollectibles() throws {
        let currentUser = try DiscordREST.decoder.decode(CurrentUser.self, from: Data("""
        {
          "id": "1",
          "username": "current",
          "discriminator": "0",
          "email": "current@example.com",
          "phone": null,
          "flags": 0,
          "public_flags": 0,
          "purchased_flags": null,
          "premium_type": 2,
          "nsfw_allowed": true,
          "mobile": true,
          "desktop": true,
          "mfa_enabled": false,
          "bio": null,
          "accent_color": null,
          "banner": null,
          "avatar": null,
          "collectibles": {
            "nameplate": {
              "sku_id": "789",
              "label": "Cobalt Plate",
              "palette": "Cobalt"
            }
          }
        }
        """.utf8))

        XCTAssertEqual(currentUser.collectibles?.nameplate?.sku_id, "789")
        XCTAssertEqual(currentUser.premium_type, .nitro)

        let update = try DiscordREST.decoder.decode(GuildMemberUpdate.self, from: Data("""
        {
          "guild_id": "guild",
          "roles": [],
          "user": {
            "id": "1",
            "username": "current",
            "discriminator": "0"
          },
          "nick": null,
          "avatar": null,
          "banner": null,
          "joined_at": "2026-07-10T00:00:00.000000+00:00",
          "premium_since": null,
          "deaf": false,
          "mute": false,
          "pending": false,
          "communication_disabled_until": null,
          "collectibles": {
            "nameplate": {
              "skuId": "987",
              "label": "Guild Plate",
              "palette": "Violet"
            }
          }
        }
        """.utf8))

        XCTAssertEqual(update.collectibles?.nameplate?.sku_id, "987")
    }

    func testInvalidNestedNameplateFallsBackToNil() throws {
        let user = try DiscordREST.decoder.decode(User.self, from: Data("""
        {
          "id": "1",
          "username": "user",
          "discriminator": "0",
          "collectibles": {
            "nameplate": {
              "sku_id": "123",
              "palette": "Sky"
            }
          }
        }
        """.utf8))

        XCTAssertNil(user.collectibles?.nameplate)
    }

    func testOptionalNameplateFieldsIgnoreInvalidTypes() throws {
        let user = try DiscordREST.decoder.decode(User.self, from: Data("""
        {
          "id": "1",
          "username": "user",
          "discriminator": "0",
          "collectibles": {
            "nameplate": {
              "sku_id": "123",
              "label": "Sky Plate",
              "palette": "Sky",
              "asset": 123,
              "expires_at": "tomorrow"
            }
          }
        }
        """.utf8))

        let nameplate = try XCTUnwrap(user.collectibles?.nameplate)
        XCTAssertNil(nameplate.asset)
        XCTAssertNil(nameplate.expires_at)
    }

    func testStaticImageURLUsesCollectiblesShopStaticRoute() {
        XCTAssertEqual(
            ProfileNameplate.staticImageURL(skuID: "123").absoluteString,
            "https://cdn.discordapp.com/media/v1/collectibles-shop/123/static"
        )
    }
}
