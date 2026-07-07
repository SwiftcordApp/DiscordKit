//
//  MessageReadAck.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 28/2/22.
//

import Foundation

public struct MessageReadAck: Codable {
    public init(token: String? = nil) {
        self.token = token
    }

    public let token: String?
}

public struct MessageReadAckBody: Codable {
    public init(
        token: String? = nil,
        last_viewed: Int? = nil,
        flags: Int? = nil
    ) {
        self.token = token
        self.last_viewed = last_viewed
        self.flags = flags
    }

    public let token: String?
    public let last_viewed: Int?
    public let flags: Int?
}
