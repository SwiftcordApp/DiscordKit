//
//  File.swift
//  
//
//  Created by Vincent Kwok on 1/6/22.
//

import Foundation

public typealias HashedAsset = String

public extension HashedAsset {
    enum AssetFormat: String {
        case jpeg = "jpg"
        case png = "png"
        case webp = "webp"
        case gif = "gif"
    }

    private static func joinPaths(with format: AssetFormat, _ paths: String...) -> URL {
        var base = URL(string: DiscordKitConfig.default.cdnURL)!

        for path in paths { base.appendPathComponent(path) }
        base.appendPathExtension(format.rawValue)

        return base
    }
}

public extension HashedAsset {
    // TODO: Validate requested format

    /// Returns the avatar URL of a user
    ///
    /// > This resource might be animated. It is animated if the hash begins with `a_`, and will
    /// > be available in GIF format as well.
    ///
    /// - Parameters:
    ///  - userID: ID of user
    ///  - format: Format of banner (PNG, JPEG, WebP, GIF)
    ///  - size: Size of asset, a power of 2 from 16 to 4096
    func avatarURL(
        of userID: Snowflake,
        with format: AssetFormat = .png,
        size: Int? = nil
    ) -> URL {
        return HashedAsset.joinPaths(with: format, "avatars", userID, self)
            .setSize(size: size)
    }

    /// Returns the banner URL of a guild or user
    ///
    /// > This resource might be animated. It is animated if the hash begins with `a_`, and will
    /// > be available in GIF format as well.
    ///
    /// - Parameters:
    ///  - id: ID of guild or user
    ///  - format: Format of banner (PNG, JPEG, WebP, GIF)
    ///  - size: Size of asset, a power of 2 from 16 to 4096
    func bannerURL(
        of id: Snowflake,
        with format: AssetFormat = .png,
        size: Int? = nil
    ) -> URL {
        return HashedAsset.joinPaths(with: format, "banners", id, self)
            .setSize(size: size)
    }

    /// Returns the icon URL of a guild
    ///
    /// > This resource might be animated. It is animated if the hash begins with `a_`, and will
    /// > be available in GIF format as well.
    ///
    /// - Parameters:
    ///  - id: ID of guild
    ///  - format: Format of icon (PNG, JPEG, WebP, GIF)
    ///  - size: Size of asset, a power of 2 from 16 to 4096
    func guildIconURL(
        of guildID: Snowflake,
        with format: AssetFormat = .png,
        size: Int? = nil
    ) -> URL {
        return HashedAsset.joinPaths(with: format, "icons", guildID, self)
            .setSize(size: size)
    }

    /// Returns the icon URL of a sticker pack banner
    ///
    /// > This resource will not be animated.
    ///
    /// - Parameters:
    ///  - format: Format of banner (PNG, JPEG, WebP)
    ///  - size: Size of asset, a power of 2 from 16 to 4096
    func stickerPackBannerURL(
        with format: AssetFormat = .png,
        size: Int? = nil
    ) -> URL {
        return HashedAsset.joinPaths(with: format, "app-assets", "710982414301790216", "store", self)
            .setSize(size: size)
    }
}

public extension HashedAsset {
    /// Get the default avatar image of a provided user discriminator
    ///
    /// - Parameter discriminator: User discriminator string
    static func defaultAvatar(of discriminator: String) -> URL {
        return HashedAsset.joinPaths(
            with: .png,
            "embed", "avatars", String((Int(discriminator) ?? 0) % 5)
        )
    }
}
