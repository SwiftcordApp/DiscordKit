//
//  UserProfileTests.swift
//
//  Created by Vincent on 18/6/26.
//

import XCTest
@testable import DiscordKitCore

final class UserProfileTests: XCTestCase {
    func testUserProfileDecodesPopoutPayload() throws {
        let profile = try DiscordREST.decoder.decode(UserProfile.self, from: Data(Self.payload.utf8))

        XCTAssertEqual(profile.user.id, "1466493625189007591")
        XCTAssertEqual(profile.user.global_name, "exy\u{00B2}")
        let joinedAt = try XCTUnwrap(profile.guild_member?.joined_at)
        XCTAssertEqual(joinedAt.timeIntervalSince1970, 1769956158.332, accuracy: 0.001)
        XCTAssertEqual(profile.user_profile?.pronouns, "")
        XCTAssertEqual(profile.badges.first?.id, "quest_completed")
        XCTAssertEqual(profile.mutual_friends?.first?.username, "belgamoscope")
        XCTAssertEqual(profile.mutual_friends_count, 1)
        XCTAssertEqual(profile.mutual_guilds?.map(\.id), [
            "1417976730303463436",
            "964741354112577557"
        ])
        XCTAssertEqual(profile.user_profile?.theme_colors?[0], 3539984)
        XCTAssertEqual(profile.user_profile?.theme_colors?[1], 0)
        XCTAssertEqual(profile.guild_member_profile?.guild_id, "964741354112577557")
        XCTAssertEqual(profile.guild_member_profile?.theme_colors?[0], 0)
        XCTAssertNil(profile.guild_member_profile?.theme_colors?[1])
    }

    func testUserProfileEffectProductDecodesCollectiblesProductPayload() throws {
        let product = try DiscordREST.decoder.decode(
            UserProfileEffectProduct.self,
            from: Data(Self.effectProductPayload.utf8)
        )

        XCTAssertEqual(product.sku_id, "1447654091193978940")
        XCTAssertEqual(product.name, "Libra")
        XCTAssertEqual(product.styles?.background_colors, [197388, 725849])
        XCTAssertEqual(product.google_sku_ids?["5"], "1447654091193978940_1447723406102630621")

        let item = try XCTUnwrap(product.items.first)
        XCTAssertEqual(item.animationType, 1)
        XCTAssertEqual(item.accessibilityLabel, "Glowing blue-white figure.")
        XCTAssertEqual(item.effects.count, 2)

        let entryEffect = item.effects[0]
        XCTAssertEqual(entryEffect.src, "https://cdn.discordapp.com/assets/content/entry")
        XCTAssertFalse(entryEffect.loop)
        XCTAssertEqual(entryEffect.width, 450)
        XCTAssertEqual(entryEffect.height, 880)
        XCTAssertEqual(entryEffect.start, 0)
        XCTAssertEqual(entryEffect.zIndex, 100)

        let ambientEffect = item.effects[1]
        XCTAssertTrue(ambientEffect.loop)
        XCTAssertEqual(ambientEffect.start, 4000)
        XCTAssertEqual(ambientEffect.position.x, 12)
        XCTAssertEqual(ambientEffect.position.y, 24)
    }

    func testUserProfileDefaultsMissingArrays() throws {
        let profile = try DiscordREST.decoder.decode(
            UserProfile.self,
            from: Data("""
            {
              "user": {
                "id": "1",
                "username": "user",
                "discriminator": "0"
              }
            }
            """.utf8)
        )

        XCTAssertTrue(profile.connected_accounts.isEmpty)
        XCTAssertTrue(profile.badges.isEmpty)
        XCTAssertTrue(profile.guild_badges.isEmpty)
    }

    func testUserProfileEffectProductDefaultsMissingAndNullValues() throws {
        let product = try DiscordREST.decoder.decode(
            UserProfileEffectProduct.self,
            from: Data("""
            {
              "sku_id": "1447654091193978940",
              "name": "Libra",
              "items": [
                {
                  "effects": [
                    {
                      "src": "https://cdn.discordapp.com/assets/content/defaults",
                      "loop": null,
                      "height": null,
                      "width": null,
                      "start": null,
                      "position": null,
                      "zIndex": null,
                      "randomizedSources": null
                    }
                  ]
                }
              ]
            }
            """.utf8)
        )

        let item = try XCTUnwrap(product.items.first)
        let effect = try XCTUnwrap(item.effects.first)
        XCTAssertFalse(effect.loop)
        XCTAssertEqual(effect.height, 0)
        XCTAssertEqual(effect.width, 0)
        XCTAssertEqual(effect.start, 0)
        XCTAssertEqual(effect.position.x, 0)
        XCTAssertEqual(effect.position.y, 0)
        XCTAssertEqual(effect.zIndex, 0)
        XCTAssertTrue(effect.randomizedSources.isEmpty)
    }

    private static let payload = """
    {
      "user": {
        "id": "1466493625189007591",
        "username": "_exyron2_",
        "global_name": "exy\\u00b2",
        "avatar": "3b0214c7d3768a9406e279a4d6536fae",
        "avatar_decoration_data": null,
        "collectibles": null,
        "discriminator": "0",
        "display_name_styles": null,
        "public_flags": 0,
        "primary_guild": null,
        "clan": null,
        "flags": 0,
        "banner": null,
        "banner_color": null,
        "accent_color": null,
        "bio": ""
      },
      "connected_accounts": [],
      "premium_type": 0,
      "premium_since": null,
      "premium_guild_since": null,
      "profile_themes_experiment_bucket": 4,
      "user_profile": {
        "bio": "",
        "accent_color": null,
        "pronouns": "",
        "profile_effect": null,
        "collectibles": [],
        "theme_colors": [3539984, 0]
      },
      "badges": [
        {
          "id": "quest_completed",
          "description": "Completed a Quest",
          "icon": "7d9ae358c8c5e118768335dbe68b4fb8",
          "link": "https://discord.com/discovery/quests"
        }
      ],
      "guild_badges": [],
      "widgets": [],
      "wishlist_settings": {
        "1500109341037170821": {
          "visibility": 1,
          "updated_at": "2026-05-02T12:18:57.659404+00:00"
        }
      },
      "mutual_friends": [
        {
          "id": "1469357985351336119",
          "username": "belgamoscope",
          "global_name": "Neimy",
          "avatar": "ce076fc44b387e2e0c642392a74b9c3d",
          "avatar_decoration_data": null,
          "collectibles": null,
          "discriminator": "0",
          "display_name_styles": {
            "font_id": 4,
            "effect_id": 1,
            "colors": []
          },
          "public_flags": 0,
          "primary_guild": null,
          "clan": null
        }
      ],
      "mutual_friends_count": 1,
      "mutual_guilds": [
        {
          "id": "1417976730303463436",
          "nick": null
        },
        {
          "id": "964741354112577557",
          "nick": null
        }
      ],
      "guild_member": {
        "avatar": null,
        "banner": null,
        "communication_disabled_until": null,
        "flags": 106,
        "joined_at": "2026-02-01T14:29:18.332000+00:00",
        "nick": null,
        "pending": false,
        "premium_since": null,
        "roles": [],
        "unusual_dm_activity_until": null,
        "user": {
          "id": "1466493625189007591",
          "username": "_exyron2_",
          "global_name": "exy\\u00b2",
          "avatar": "3b0214c7d3768a9406e279a4d6536fae",
          "avatar_decoration_data": null,
          "collectibles": null,
          "discriminator": "0",
          "display_name_styles": null,
          "public_flags": 0,
          "primary_guild": null,
          "clan": null
        },
        "bio": "",
        "mute": false,
        "deaf": false
      },
      "guild_member_profile": {
        "guild_id": "964741354112577557",
        "pronouns": "",
        "profile_effect": null,
        "collectibles": [],
        "theme_colors": [0, null]
      },
      "legacy_username": null
    }
    """

    private static let effectProductPayload = """
    {
      "sku_id": "1447654091193978940",
      "name": "Libra",
      "summary": "Show this effect when others view your profile.",
      "store_listing_id": "1447654091193978940",
      "styles": {
        "background_colors": [197388, 725849],
        "button_colors": [5793266, 5793266],
        "confetti_colors": [43772, 15774258]
      },
      "preview_assets": null,
      "items": [
        {
          "type": 1,
          "sku_id": "1447654091193978940",
          "title": "Libra",
          "description": "Show this effect when others view your profile.",
          "accessibilityLabel": "Glowing blue-white figure.",
          "animationType": 1,
          "staticFrameSrc": "https://cdn.discordapp.com/assets/content/static",
          "thumbnailPreviewSrc": "https://cdn.discordapp.com/assets/content/thumbnail",
          "reducedMotionSrc": "https://cdn.discordapp.com/assets/content/reduced",
          "effects": [
            {
              "src": "https://cdn.discordapp.com/assets/content/entry",
              "loop": false,
              "height": 880,
              "width": 450,
              "duration": 4000,
              "start": 0,
              "loopDelay": 0,
              "position": { "x": 0, "y": 0 },
              "zIndex": 100,
              "randomizedSources": []
            },
            {
              "src": "https://cdn.discordapp.com/assets/content/ambient",
              "loop": true,
              "height": 880,
              "width": 450,
              "duration": 5000,
              "start": 4000,
              "loopDelay": 0,
              "position": { "x": 12, "y": 24 },
              "zIndex": 101,
              "randomizedSources": []
            }
          ]
        }
      ],
      "type": 1,
      "premium_type": 0,
      "category_sku_id": "1447654091630182572",
      "google_sku_ids": {
        "5": "1447654091193978940_1447723406102630621"
      }
    }
    """
}
