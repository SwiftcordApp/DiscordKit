//
//  Reaction.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

public struct Reaction: Codable {
    public let count: Int
    public let me: Bool // swiftlint:disable:this identifier_name
    public let emoji: Emoji
}
