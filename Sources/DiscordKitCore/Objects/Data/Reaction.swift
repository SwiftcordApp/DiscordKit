//
//  Reaction.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

public struct Reaction: Codable {
    public init(count: Int, me: Bool, emoji: Emoji) {
        self.count = count
        self.me = me
        self.emoji = emoji
    }

    public let count: Int
    public let me: Bool // swiftlint:disable:this identifier_name
    public let emoji: Emoji
}
