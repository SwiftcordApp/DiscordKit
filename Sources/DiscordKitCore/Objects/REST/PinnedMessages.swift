//
//  PinnedMessages.swift
//  DiscordKit
//
//  Created by Vincent on 18/8/26.
//

import Foundation

/// One page returned by Discord's timestamp-paginated pinned-message endpoint.
public struct PinnedMessagesPage: Decodable {
    public let items: [PinnedMessageItem]
    public let hasMore: Bool

    public init(items: [PinnedMessageItem], hasMore: Bool) {
        self.items = items
        self.hasMore = hasMore
    }

    private enum CodingKeys: String, CodingKey {
        case items
        case hasMore = "has_more"
    }
}

/// A pinned message and the server timestamp used to paginate the pins list.
public struct PinnedMessageItem: Decodable {
    public let pinnedAt: Date
    public let message: Message

    public init(pinnedAt: Date, message: Message) {
        self.pinnedAt = pinnedAt
        self.message = message
    }

    private enum CodingKeys: String, CodingKey {
        case pinnedAt = "pinned_at"
        case message
    }
}

struct PinnedMessagesQuery {
    let limit: Int
    let before: Date?

    func queryItems() -> [URLQueryItem] {
        var items = [URLQueryItem(name: "limit", value: String(limit))]
        if let before {
            items.append(URLQueryItem(
                name: "before",
                value: iso8601WithFractionalSeconds.string(from: before)
            ))
        }
        return items
    }
}
