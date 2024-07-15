//
//  MessageReadAck.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 28/2/22.
//

import Foundation

public struct MessageReadAck: Codable {
    public let token: String?
    public let last_viewed: Int?
    
    public let manual: Bool?
    public let mention_count: Int?
}
