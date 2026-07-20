//
//  MessageSearch.swift
//  DiscordKit
//
//  Created by Vincent on 19/7/26.
//

import Foundation

/// Query fields for the legacy message-search endpoints
public struct MessageSearchQuery {
    public enum SortBy: String {
        case timestamp
        case relevance
    }

    public enum SortOrder: String {
        case asc
        case desc
    }

    public var content: String?
    public var authorIDs: [Snowflake]
    public var mentions: [Snowflake]
    public var has: [String]
    public var linkHostnames: [String]
    public var attachmentExtensions: [String]
    public var attachmentFilenames: [String]
    public var minID: Snowflake?
    public var maxID: Snowflake?
    public var channelIDs: [Snowflake]
    public var pinned: [Bool]
    public var authorTypes: [String]
    public var sortBy: SortBy
    public var sortOrder: SortOrder
    public var offset: Int
    public var includeNSFW: Bool?
    /// Retry counter the official client adds to `202 Accepted` retries
    public var attempts: Int?

    public init(
        content: String? = nil,
        authorIDs: [Snowflake] = [],
        mentions: [Snowflake] = [],
        has: [String] = [],
        linkHostnames: [String] = [],
        attachmentExtensions: [String] = [],
        attachmentFilenames: [String] = [],
        minID: Snowflake? = nil,
        maxID: Snowflake? = nil,
        channelIDs: [Snowflake] = [],
        pinned: [Bool] = [],
        authorTypes: [String] = [],
        sortBy: SortBy = .timestamp,
        sortOrder: SortOrder = .desc,
        offset: Int = 0,
        includeNSFW: Bool? = nil,
        attempts: Int? = nil
    ) {
        self.content = content
        self.authorIDs = authorIDs
        self.mentions = mentions
        self.has = has
        self.linkHostnames = linkHostnames
        self.attachmentExtensions = attachmentExtensions
        self.attachmentFilenames = attachmentFilenames
        self.minID = minID
        self.maxID = maxID
        self.channelIDs = channelIDs
        self.pinned = pinned
        self.authorTypes = authorTypes
        self.sortBy = sortBy
        self.sortOrder = sortOrder
        self.offset = offset
        self.includeNSFW = includeNSFW
        self.attempts = attempts
    }

    /// Whether any filter field would be sent — a query with none should not
    /// be submitted at all
    public var hasFilters: Bool {
        content?.isEmpty == false
            || !authorIDs.isEmpty
            || !mentions.isEmpty
            || !has.isEmpty
            || !linkHostnames.isEmpty
            || !attachmentExtensions.isEmpty
            || !attachmentFilenames.isEmpty
            || minID != nil
            || maxID != nil
            || !channelIDs.isEmpty
            || !pinned.isEmpty
            || !authorTypes.isEmpty
    }

    /// Compose final query items
    ///
    /// Arrays become repeated query keys without `[]` suffixes, booleans are
    /// encoded as `true`/`false`, and no `limit` is sent - the endpoint's default page size (25) applies.
    public func queryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []
        func add(_ name: String, _ value: String?) {
            guard let value, !value.isEmpty else { return }
            items.append(URLQueryItem(name: name, value: value))
        }
        func add(_ name: String, values: [String]) {
            for value in values { add(name, value) }
        }

        add("content", content)
        add("author_id", values: authorIDs)
        add("mentions", values: mentions)
        add("has", values: has)
        add("link_hostname", values: linkHostnames)
        add("attachment_extension", values: attachmentExtensions)
        add("attachment_filename", values: attachmentFilenames)
        add("min_id", minID)
        add("max_id", maxID)
        add("channel_id", values: channelIDs)
        add("pinned", values: pinned.map(String.init))
        add("author_type", values: authorTypes)
        add("sort_by", sortBy.rawValue)
        add("sort_order", sortOrder.rawValue)
        items.append(URLQueryItem(name: "offset", value: String(offset)))
        if let includeNSFW {
            add("include_nsfw", String(includeNSFW))
        }
        if let attempts {
            add("attempts", String(attempts))
        }
        return items
    }
}

/// Successful response of the legacy message-search endpoints
///
/// `messages` is a list of result groups: the first element of each group is
/// the primary hit, the rest are surrounding/referenced messages provided for
/// rendering and hydration.
public struct MessageSearchResults: Decodable {
    public let analytics_id: String?
    public let total_results: Int
    public let messages: [[DecodeThrowable<Message>]]
    public let threads: [DecodeThrowable<Channel>]?
    public let members: [ThreadMember]?
    public let channels: [DecodeThrowable<Channel>]?
    public let doing_deep_historical_index: Bool?
    public let documents_indexed: Int?
}

public enum MessageSearchOutcome {
    case results(MessageSearchResults)
    /// The server is still building the search index (`202 Accepted`); retry
    /// after the given delay
    case indexing(retryAfter: TimeInterval)
}
