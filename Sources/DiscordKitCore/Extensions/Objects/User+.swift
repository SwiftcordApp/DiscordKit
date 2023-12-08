//
//  User+.swift
//
//
//  Created by Vincent Kwok on 8/12/23.
//

import Foundation

public extension User {
    func avatarURL(size: Int? = nil) -> URL {
        avatar?.avatarURL(of: id, size: size)
        // If user is without a set avatar, display one of the default ones.
        // These do not have support for custom sizes.
        ?? URL(string: "\(DiscordKitConfig.default.cdnURL)embed/avatars/\((Int(discriminator) ?? 0) % 5).png")!
    }
}
