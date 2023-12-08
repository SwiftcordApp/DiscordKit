//
//  Message+.swift
//
//
//  Created by Vincent Kwok on 8/12/23.
//

import Foundation

public extension Message {
    func mentions(_ userID: Snowflake?) -> Bool {
        guard let userID else { return false }
        return mentions.first(identifiedBy: userID) != nil
    }
}

// MARK: Protocol Conformance
extension Message: Equatable, Hashable {
    public static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id && lhs.content == rhs.content && lhs.attachments == rhs.attachments && lhs.embeds == rhs.embeds
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(content)
        hasher.combine(attachments)
        hasher.combine(embeds)
    }
}
