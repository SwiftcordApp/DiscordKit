//
//  User+.swift
//
//
//  Created by Vincent Kwok on 8/12/23.
//

import Foundation

@inline(__always)
private func _avatar(_ asset: HashedAsset?, size: Int?, discrim: String, id: Snowflake) -> URL {
    if let url = asset?.avatarURL(of: id, size: size) {
        return url
    }
    let index = discrim == "0"
        ? ((UInt(id) ?? 0) >> 22) % 6
        : (UInt(discrim) ?? 0) % 5
    // If user is without a set avatar, display one of the default ones.
    // These do not have support for custom sizes.
    return URL(string: "\(DiscordKitConfig.default.cdnURL)embed/avatars/\(index).png")!
}

public extension User {
    func avatarURL(size: Int? = nil) -> URL {
        _avatar(avatar, size: size, discrim: discriminator, id: id)
    }
}

public extension CurrentUser {
    func avatarURL(size: Int? = nil) -> URL {
        _avatar(avatar, size: size, discrim: discriminator, id: id)
    }
}
