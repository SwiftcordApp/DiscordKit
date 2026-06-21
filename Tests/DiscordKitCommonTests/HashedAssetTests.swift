//
//  HashedAssetTests.swift
//
//  Created by Vincent on 21/6/26.
//

import XCTest
import DiscordKitCore

final class HashedAssetTests: XCTestCase {
    func testGuildMemberBannerURLUsesGuildScopedUserBannerRoute() {
        let asset: HashedAsset<GuildMemberBanner> = "banner_hash"
        let url = asset.scoped(
            to: "1466493625189007591",
            in: "964741354112577557"
        ).url(
            size: 600
        )

        XCTAssertEqual(
            url.absoluteString,
            "https://cdn.discordapp.com/guilds/964741354112577557/users/1466493625189007591/banners/banner_hash.png?size=600"
        )
    }

    func testAnimatedAssetHashDetection() {
        let animated: HashedAsset<UserBanner> = "a_banner_hash"
        let staticAsset: HashedAsset<UserBanner> = "banner_hash"

        XCTAssertTrue(animated.isAnimated)
        XCTAssertFalse(staticAsset.isAnimated)
    }

    func testAnimatedBannerURLUsesAnimatedWebPWhenRequested() {
        let asset: HashedAsset<UserBanner> = "a_banner_hash"
        let url = asset.scoped(
            to: "1466493625189007591"
        ).url(
            size: 600,
            animated: true
        )

        XCTAssertEqual(
            url.absoluteString,
            "https://cdn.discordapp.com/banners/1466493625189007591/a_banner_hash.webp?animated=true&size=600"
        )
    }

    func testAnimatedFlagDoesNotSetAnimatedQueryForStaticBannerHash() {
        let asset: HashedAsset<UserBanner> = "banner_hash"
        let url = asset.scoped(
            to: "1466493625189007591"
        ).url(
            size: 600,
            animated: true
        )

        XCTAssertEqual(
            url.absoluteString,
            "https://cdn.discordapp.com/banners/1466493625189007591/banner_hash.png?size=600"
        )
    }

    func testSetAnimatedFalseRemovesAnimatedQueryItem() {
        let url = URL(string: "https://cdn.discordapp.com/banners/1466493625189007591/a_banner_hash.webp?animated=true&size=600")!
            .setAnimated(animated: false)

        XCTAssertEqual(
            url.absoluteString,
            "https://cdn.discordapp.com/banners/1466493625189007591/a_banner_hash.webp?size=600"
        )
    }

    func testStaticAssetKindDoesNotUseAnimatedWebPForAnimatedLookingHash() {
        let asset: HashedAsset<StickerPackBanner> = "a_banner_hash"
        let url = asset.url(animated: true)

        XCTAssertEqual(
            url.absoluteString,
            "https://cdn.discordapp.com/app-assets/710982414301790216/store/a_banner_hash.png"
        )
    }
}
