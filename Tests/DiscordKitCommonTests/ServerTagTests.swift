//
//  ServerTagTests.swift
//  DiscordKitTests
//
//  Created by Vincent on 1/8/26.
//

import XCTest
@testable import DiscordKitCore

final class ServerTagTests: XCTestCase {
    func testUserDecodesPrimaryGuildIdentity() throws {
        let user = try decode(User.self, json: Self.userJSON(primaryGuild: """
        {
          "identity_guild_id": "guild",
          "identity_enabled": true,
          "tag": "CORD",
          "badge": "badge-token"
        }
        """))

        XCTAssertEqual(user.primary_guild?.identity_guild_id, "guild")
        XCTAssertEqual(user.primary_guild?.identity_enabled, true)
        XCTAssertEqual(user.primary_guild?.tag, "CORD")
        XCTAssertEqual(user.primary_guild?.badge?.rawValue, "badge-token")
    }

    func testPrimaryGuildMayBeMissingOrNull() throws {
        let missing = try decode(User.self, json: Self.userJSON())
        let null = try decode(User.self, json: Self.userJSON(primaryGuild: "null"))

        XCTAssertNil(missing.primary_guild)
        XCTAssertNil(null.primary_guild)
    }

    func testCurrentAndPresenceUsersDecodePrimaryGuild() throws {
        let current = try decode(CurrentUser.self, json: Self.userJSON(primaryGuild: Self.identityJSON))
        let presence = try decode(PresenceUser.self, json: """
        {
          "id": "user",
          "primary_guild": \(Self.identityJSON)
        }
        """)

        XCTAssertEqual(current.primary_guild?.tag, "CORD")
        XCTAssertEqual(presence.primary_guild, current.primary_guild)
        XCTAssertEqual(User(from: current).primary_guild, current.primary_guild)
    }

    func testServerTagBadgeUsesClanBadgeCDNRoute() throws {
        let identity = UserPrimaryGuild(
            identity_guild_id: "guild",
            identity_enabled: true,
            tag: "CORD",
            badge: "badge-token"
        )

        XCTAssertEqual(
            identity.badgeAsset?.url(size: 16).absoluteString,
            "https://cdn.discordapp.com/clan-badges/guild/badge-token.png?size=16"
        )
    }

    func testProfileQuarantineUsesOnlyMemberFlags() throws {
        for flag in [128, 256, 1024] {
            let member = try decode(Member.self, json: Self.memberJSON(flags: flag))
            XCTAssertTrue(member.isAnyProfileFieldQuarantined)
        }

        XCTAssertFalse(try decode(Member.self, json: Self.memberJSON(flags: 0)).isAnyProfileFieldQuarantined)
        XCTAssertFalse(try decode(Member.self, json: Self.memberJSON(flags: 512)).isAnyProfileFieldQuarantined)
        XCTAssertFalse(try decode(Member.self, json: Self.memberJSON(flags: nil)).isAnyProfileFieldQuarantined)
    }

    private func decode<Value: Decodable>(_ type: Value.Type, json: String) throws -> Value {
        try DiscordREST.decoder.decode(type, from: Data(json.utf8))
    }

    private static let identityJSON = """
    {
      "identity_guild_id": "guild",
      "identity_enabled": true,
      "tag": "CORD",
      "badge": "badge-token"
    }
    """

    private static func userJSON(primaryGuild: String? = nil) -> String {
        let identityField = primaryGuild.map { ",\n  \"primary_guild\": \($0)" } ?? ""
        return """
        {
          "id": "user",
          "username": "user",
          "discriminator": "0"\(identityField)
        }
        """
    }

    private static func memberJSON(flags: Int?) -> String {
        let flagsField = flags.map { ",\n  \"flags\": \($0)" } ?? ""
        return """
        {
          "roles": [],
          "joined_at": "2026-08-01T00:00:00Z",
          "deaf": false,
          "mute": false\(flagsField)
        }
        """
    }
}
