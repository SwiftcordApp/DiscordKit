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
}
