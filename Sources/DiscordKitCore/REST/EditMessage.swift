//
//  EditMessage.swift
//  DiscordAPI
//
//  Created by Vincent on 25/6/26.
//

import Foundation

public struct EditMessage: Encodable {
    public let content: String

    public init(content: String) {
        self.content = content
    }
}
